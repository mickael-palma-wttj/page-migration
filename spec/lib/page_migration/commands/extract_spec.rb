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
  let(:json_data) { org_data.to_json }
  let(:mock_conn) { double("connection") }
  let(:mock_query) { instance_double(PageMigration::Queries::OrganizationQuery, call: json_data) }

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

    context "with text format" do
      subject(:command) { described_class.new(org_ref, format: "text") }
      let(:text_generator) { instance_double(PageMigration::Generators::TextContentGenerator, generate: "Content") }

      before do
        allow(PageMigration::Generators::TextContentGenerator).to receive(:new).and_return(text_generator)
      end

      it "uses TextContentGenerator" do
        expect(PageMigration::Generators::TextContentGenerator).to receive(:new)
          .with(anything, language: "fr")
        expect { command.call }.to output.to_stdout
      end

      it "writes text to output file" do
        expect(File).to receive(:write).with(/contenu_fr\.txt$/, "Content")
        expect { command.call }.to output(/Text content extracted/).to_stdout
      end
    end

    context "with custom output path" do
      subject(:command) { described_class.new(org_ref, output: "custom/path.json") }

      it "uses the custom output path" do
        expect(File).to receive(:write).with("custom/path.json", anything)
        expect { command.call }.to output.to_stdout
      end
    end

    context "with language option" do
      subject(:command) { described_class.new(org_ref, format: "text", language: "en") }
      let(:text_generator) { instance_double(PageMigration::Generators::TextContentGenerator, generate: "Content") }

      before do
        allow(PageMigration::Generators::TextContentGenerator).to receive(:new).and_return(text_generator)
      end

      it "passes language to generator" do
        expect(PageMigration::Generators::TextContentGenerator).to receive(:new)
          .with(anything, language: "en")
        expect { command.call }.to output.to_stdout
      end
    end
  end

  describe "FORMATS" do
    it "supports json and text" do
      expect(described_class::FORMATS).to eq(%w[json text])
    end
  end
end
