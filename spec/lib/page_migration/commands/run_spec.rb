# frozen_string_literal: true

RSpec.describe PageMigration::Commands::Run do
  let(:org_ref) { "Pg4eV6k" }
  let(:command) { described_class.new(org_ref) }

  describe "#call" do
    let(:extract_command) { instance_double(PageMigration::Commands::Extract, call: "tmp/output.json") }
    let(:convert_command) { instance_double(PageMigration::Commands::Convert, call: nil) }

    before do
      allow(PageMigration::Commands::Extract).to receive(:new).and_return(extract_command)
      allow(PageMigration::Commands::Convert).to receive(:new).and_return(convert_command)
    end

    it "runs extract command" do
      expect(PageMigration::Commands::Extract).to receive(:new).with(org_ref, output: nil)
      expect { command.call }.to output(/Running full pipeline/).to_stdout
    end

    it "runs convert command with extract output" do
      expect(PageMigration::Commands::Convert).to receive(:new)
        .with(input: "tmp/output.json", output_dir: PageMigration::Commands::Convert::DEFAULT_OUTPUT_DIR)
      expect { command.call }.to output.to_stdout
    end

    it "outputs progress messages" do
      expect { command.call }.to output(/Step 1: Extract.*Step 2: Convert.*Pipeline complete/m).to_stdout
    end
  end

  describe "with custom options" do
    let(:command) { described_class.new(org_ref, json_output: "custom.json", md_output_dir: "output/") }
    let(:extract_command) { instance_double(PageMigration::Commands::Extract, call: "custom.json") }
    let(:convert_command) { instance_double(PageMigration::Commands::Convert, call: nil) }

    before do
      allow(PageMigration::Commands::Extract).to receive(:new).and_return(extract_command)
      allow(PageMigration::Commands::Convert).to receive(:new).and_return(convert_command)
    end

    it "passes custom json_output to extract" do
      expect(PageMigration::Commands::Extract).to receive(:new).with(org_ref, output: "custom.json")
      expect { command.call }.to output.to_stdout
    end

    it "passes custom md_output_dir to convert" do
      expect(PageMigration::Commands::Convert).to receive(:new).with(input: "custom.json", output_dir: "output/")
      expect { command.call }.to output.to_stdout
    end
  end
end
