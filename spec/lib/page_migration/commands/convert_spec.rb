# frozen_string_literal: true

RSpec.describe PageMigration::Commands::Convert do
  let(:org_data) do
    [{
      "name" => "Test Company",
      "reference" => "TestRef",
      "pages" => []
    }]
  end
  let(:mock_generator) { instance_double(PageMigration::MarkdownGenerator, generate: "# Content") }

  before do
    allow(PageMigration::Support::JsonLoader).to receive(:load).and_return(org_data)
    allow(PageMigration::MarkdownGenerator).to receive(:new).and_return(mock_generator)
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:write)
  end

  describe "#call" do
    context "with explicit input file" do
      let(:command) { described_class.new(input: "input.json") }

      it "loads JSON from input file" do
        expect(PageMigration::Support::JsonLoader).to receive(:load).with("input.json")
        expect { command.call }.to output.to_stdout
      end

      it "generates markdown for each organization" do
        expect(PageMigration::MarkdownGenerator).to receive(:new).with(org_data.first)
        expect { command.call }.to output.to_stdout
      end

      it "writes output files" do
        expect(File).to receive(:write).with(/TestRef_test_company\.md$/, "# Content")
        expect { command.call }.to output.to_stdout
      end
    end

    context "with org_ref" do
      let(:command) { described_class.new("Pg4eV6k") }

      before do
        allow(PageMigration::Support::FileDiscovery).to receive(:find_query_json!)
          .and_return("tmp/query_result/Pg4eV6k_company/query.json")
      end

      it "finds input file by org_ref" do
        expect(PageMigration::Support::FileDiscovery).to receive(:find_query_json!).with("Pg4eV6k")
        expect { command.call }.to output.to_stdout
      end
    end

    context "without input or org_ref" do
      let(:command) { described_class.new }

      before do
        allow(PageMigration::Support::FileDiscovery).to receive(:find_latest_query_json)
          .and_return("tmp/query_result/latest/query.json")
      end

      it "finds latest query JSON" do
        expect(PageMigration::Support::FileDiscovery).to receive(:find_latest_query_json)
        expect { command.call }.to output.to_stdout
      end

      context "when no files found" do
        before do
          allow(PageMigration::Support::FileDiscovery).to receive(:find_latest_query_json).and_return(nil)
        end

        it "falls back to default path" do
          expect(PageMigration::Support::JsonLoader).to receive(:load).with("tmp/query_result/query.json")
          expect { command.call }.to output.to_stdout
        end
      end
    end

    context "with custom output_dir" do
      let(:command) { described_class.new(input: "input.json", output_dir: "custom/output") }

      it "writes to custom directory" do
        expect(File).to receive(:write).with(%r{^custom/output/}, anything)
        expect { command.call }.to output.to_stdout
      end
    end
  end

  describe "DEFAULT_OUTPUT_DIR" do
    it "has a default output directory" do
      expect(described_class::DEFAULT_OUTPUT_DIR).to eq("tmp/org_markdown")
    end
  end
end
