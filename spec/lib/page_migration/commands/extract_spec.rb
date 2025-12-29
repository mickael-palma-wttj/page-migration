# frozen_string_literal: true

RSpec.describe PageMigration::Commands::Extract do
  let(:org_ref) { "Pg4eV6k" }
  let(:org_data) do
    {
      "organizations" => [{
        "name" => "Test Company",
        "reference" => org_ref,
        "pages" => []
      }]
    }
  end
  let(:tree_data) do
    {
      "page_tree" => [],
      "organization" => {"reference" => org_ref, "name" => "Test Company"}
    }
  end
  let(:json_data) { org_data.to_json }
  let(:tree_json) { tree_data.to_json }
  let(:mock_conn) { double("connection") }
  let(:mock_query) { instance_double(PageMigration::Queries::OrganizationQuery, call: json_data) }
  let(:mock_tree_query) { instance_double(PageMigration::Queries::PageTreeQuery, call: tree_json) }

  before do
    allow(PageMigration::Database).to receive(:with_connection).and_yield(mock_conn)
    allow(PageMigration::Queries::OrganizationQuery).to receive(:new).and_return(mock_query)
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:write)
  end

  describe "#call" do
    context "with json format (default)" do
      subject(:command) { described_class.new(org_ref) }

      it "queries the database" do
        expect(PageMigration::Queries::OrganizationQuery).to receive(:new).with(org_ref)
        expect { command.call }.to output.to_stdout
      end

      it "writes JSON to output file" do
        expect(File).to receive(:write).with(/query\.json$/, anything)
        expect { command.call }.to output(/Exported to/).to_stdout
      end

      it "returns the output path" do
        result = nil
        expect { result = command.call }.to output.to_stdout
        expect(result).to match(/query\.json$/)
      end
    end

    context "with custom output path" do
      subject(:command) { described_class.new(org_ref, output: "custom/path.json") }

      it "uses the custom output path" do
        expect(File).to receive(:write).with("custom/path.json", anything)
        expect { command.call }.to output.to_stdout
      end
    end

    context "with simple-json format" do
      subject(:command) { described_class.new(org_ref, format: "simple-json") }
      let(:simple_json_generator) { instance_double(PageMigration::Generators::SimpleJsonGenerator, to_json: "{}") }

      before do
        allow(PageMigration::Queries::PageTreeQuery).to receive(:new).and_return(mock_tree_query)
        allow(PageMigration::Generators::SimpleJsonGenerator).to receive(:new).and_return(simple_json_generator)
      end

      it "uses SimpleJsonGenerator" do
        expect(PageMigration::Generators::SimpleJsonGenerator).to receive(:new)
          .with(anything, tree_data: anything, language: "fr")
        expect { command.call }.to output.to_stdout
      end

      it "writes to .json file" do
        expect(File).to receive(:write).with(/contenu_fr\.json$/, "{}")
        expect { command.call }.to output(/Content extracted/).to_stdout
      end
    end

    context "with language option" do
      subject(:command) { described_class.new(org_ref, format: "simple-json", language: "en") }
      let(:simple_json_generator) { instance_double(PageMigration::Generators::SimpleJsonGenerator, to_json: "{}") }

      before do
        allow(PageMigration::Queries::PageTreeQuery).to receive(:new).and_return(mock_tree_query)
        allow(PageMigration::Generators::SimpleJsonGenerator).to receive(:new).and_return(simple_json_generator)
      end

      it "passes language to generator" do
        expect(PageMigration::Generators::SimpleJsonGenerator).to receive(:new)
          .with(anything, tree_data: anything, language: "en")
        expect { command.call }.to output.to_stdout
      end
    end
  end

  describe "FORMATS" do
    it "supports json and simple-json" do
      expect(described_class::FORMATS).to eq(%w[json simple-json])
    end
  end
end
