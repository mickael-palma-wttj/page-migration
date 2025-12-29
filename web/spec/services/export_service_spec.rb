# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExportService do
  describe ".find_path" do
    context "with legacy ID format" do
      it "returns legacy path if directory exists" do
        allow(File).to receive(:directory?).and_return(true)

        result = described_class.find_path("ABC123_company")

        expect(result).to include("ABC123_company")
      end

      it "returns nil if directory does not exist" do
        allow(File).to receive(:directory?).and_return(false)

        result = described_class.find_path("ABC123_company")

        expect(result).to be_nil
      end
    end

    context "with command_run:export_name format" do
      let(:command_run) { create(:command_run, :completed) }

      before do
        command_run.ensure_output_directory
      end

      after do
        FileUtils.rm_rf(command_run.output_directory)
      end

      it "returns path if export directory exists" do
        export_dir = File.join(command_run.export_data_directory, "ABC123_company")
        FileUtils.mkdir_p(export_dir)

        result = described_class.find_path("#{command_run.id}:ABC123_company")

        expect(result).to eq(export_dir)
      end

      it "returns nil if command_run not found" do
        result = described_class.find_path("999999:ABC123_company")

        expect(result).to be_nil
      end
    end
  end

  describe ".extract_org_ref" do
    it "extracts org_ref from legacy format" do
      result = described_class.extract_org_ref("ABC123_company_name")

      expect(result).to eq("ABC123")
    end

    it "extracts org_ref from command_run format" do
      result = described_class.extract_org_ref("1:ABC123_company_name")

      expect(result).to eq("ABC123")
    end
  end

  describe ".find_command_run" do
    it "returns nil for legacy format" do
      result = described_class.find_command_run("ABC123_company")

      expect(result).to be_nil
    end

    it "returns command_run for valid ID" do
      command_run = create(:command_run)

      result = described_class.find_command_run("#{command_run.id}:ABC123_company")

      expect(result).to eq(command_run)
    end
  end

  describe ".exists?" do
    let(:command_run) { create(:command_run, :completed) }

    before do
      command_run.ensure_output_directory
    end

    after do
      FileUtils.rm_rf(command_run.output_directory)
    end

    it "returns true if export directory exists for org_ref" do
      export_dir = File.join(command_run.export_data_directory, "ABC123_company")
      FileUtils.mkdir_p(export_dir)

      result = described_class.exists?("ABC123")

      expect(result).to be true
    end

    it "returns false if no export exists" do
      result = described_class.exists?("NONEXISTENT")

      expect(result).to be false
    end
  end

  describe ".list_files" do
    let(:temp_dir) { Dir.mktmpdir }

    after do
      FileUtils.rm_rf(temp_dir)
    end

    it "lists all files with metadata" do
      FileUtils.mkdir_p(File.join(temp_dir, "subdir"))
      File.write(File.join(temp_dir, "file1.json"), "{}")
      File.write(File.join(temp_dir, "subdir", "file2.md"), "# Title")

      result = described_class.list_files(temp_dir)

      expect(result.size).to eq(2)
      expect(result.map { |f| f[:name] }).to contain_exactly("file1.json", "file2.md")
      expect(result.find { |f| f[:name] == "file1.json" }[:type]).to eq(:json)
      expect(result.find { |f| f[:name] == "file2.md" }[:type]).to eq(:markdown)
    end

    it "returns files sorted by path" do
      File.write(File.join(temp_dir, "z_file.txt"), "")
      File.write(File.join(temp_dir, "a_file.txt"), "")

      result = described_class.list_files(temp_dir)

      expect(result.first[:name]).to eq("a_file.txt")
    end
  end
end
