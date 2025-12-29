# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommandRun do
  describe "validations" do
    it { is_expected.to validate_presence_of(:command) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:command).in_array(CommandRun::COMMANDS) }
    it { is_expected.to validate_inclusion_of(:status).in_array(CommandRun::STATUSES) }
  end

  describe "scopes" do
    describe ".recent" do
      it "orders by created_at descending" do
        old = create(:command_run, created_at: 1.day.ago)
        new = create(:command_run, created_at: 1.hour.ago)

        expect(described_class.recent).to eq([new, old])
      end
    end

    describe ".pending" do
      it "returns only pending command runs" do
        pending = create(:command_run, status: "pending")
        create(:command_run, :running)

        expect(described_class.pending).to eq([pending])
      end
    end

    describe ".completed" do
      it "returns only completed command runs" do
        completed = create(:command_run, :completed)
        create(:command_run, :failed)

        expect(described_class.completed).to eq([completed])
      end
    end

    describe ".stale" do
      it "returns command runs that have not been updated recently" do
        stale = create(:command_run, :running)
        stale.update_column(:updated_at, 10.minutes.ago)

        fresh = create(:command_run, :running)

        expect(described_class.stale).to include(stale)
        expect(described_class.stale).not_to include(fresh)
      end
    end
  end

  describe "status methods" do
    describe "#pending?" do
      it "returns true when status is pending" do
        command_run = build(:command_run, status: "pending")
        expect(command_run.pending?).to be true
      end
    end

    describe "#running?" do
      it "returns true when status is running" do
        command_run = build(:command_run, :running)
        expect(command_run.running?).to be true
      end
    end

    describe "#completed?" do
      it "returns true when status is completed" do
        command_run = build(:command_run, :completed)
        expect(command_run.completed?).to be true
      end
    end

    describe "#failed?" do
      it "returns true when status is failed" do
        command_run = build(:command_run, :failed)
        expect(command_run.failed?).to be true
      end
    end

    describe "#finished?" do
      it "returns true when completed or failed" do
        expect(build(:command_run, :completed).finished?).to be true
        expect(build(:command_run, :failed).finished?).to be true
        expect(build(:command_run, :running).finished?).to be false
      end
    end

    describe "#stale?" do
      it "returns true when running and not updated recently" do
        command_run = create(:command_run, :running)
        command_run.update_column(:updated_at, 10.minutes.ago)

        expect(command_run.stale?).to be true
      end

      it "returns false when recently updated" do
        command_run = create(:command_run, :running)
        expect(command_run.stale?).to be false
      end
    end
  end

  describe "#duration" do
    it "returns nil when not started" do
      command_run = build(:command_run)
      expect(command_run.duration).to be_nil
    end

    it "calculates duration for completed runs" do
      command_run = build(:command_run, started_at: 60.seconds.ago, completed_at: Time.current)
      expect(command_run.duration).to be_within(1).of(60)
    end
  end

  describe "#display_status" do
    it "returns 'interrupted' for stale runs" do
      command_run = create(:command_run, :running)
      command_run.update_column(:updated_at, 10.minutes.ago)

      expect(command_run.display_status).to eq("interrupted")
    end

    it "returns the status for non-stale runs" do
      command_run = build(:command_run, :completed)
      expect(command_run.display_status).to eq("completed")
    end
  end

  describe "output management" do
    let(:command_run) { create(:command_run) }

    after do
      FileUtils.rm_rf(command_run.output_directory) if command_run.output_directory.exist?
    end

    describe "#output=" do
      it "writes content to output file" do
        command_run.output = "test output"
        expect(command_run.output).to eq("test output")
      end
    end

    describe "#append_output" do
      it "appends content to output file" do
        command_run.output = "first "
        command_run.append_output("second")
        expect(command_run.output).to eq("first second")
      end
    end
  end

  describe "cleanup" do
    it "removes output directory on destroy" do
      command_run = create(:command_run)
      command_run.output = "test"
      output_dir = command_run.output_directory

      expect(output_dir).to exist
      command_run.destroy
      expect(output_dir).not_to exist
    end
  end
end
