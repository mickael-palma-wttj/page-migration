# frozen_string_literal: true

RSpec.describe PageMigration::Commands::ExtractTree do
  let(:org_ref) { "Pg4eV6k" }
  let(:tree_data) do
    {
      "organization" => {"name" => "Test Company", "reference" => org_ref},
      "page_tree" => []
    }
  end
  let(:json_data) { tree_data.to_json }
  let(:mock_conn) { double("connection") }
  let(:mock_query) { instance_double(PageMigration::Queries::PageTreeQuery, call: json_data) }
  let(:show_tree_command) { instance_double(PageMigration::Commands::ShowTree, call: nil) }

  before do
    allow(PageMigration::Database).to receive(:with_connection).and_yield(mock_conn)
    allow(PageMigration::Queries::PageTreeQuery).to receive(:new).and_return(mock_query)
    allow(PageMigration::Commands::ShowTree).to receive(:new).and_return(show_tree_command)
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:write)
  end

  describe "#call" do
    let(:command) { described_class.new(org_ref) }

    it "queries the database for tree data" do
      expect(PageMigration::Queries::PageTreeQuery).to receive(:new).with(org_ref)
      command.call
    end

    it "writes tree JSON to output file" do
      expect(File).to receive(:write).with(/tree\.json$/, anything)
      command.call
    end

    it "displays the tree using ShowTree" do
      expect(PageMigration::Commands::ShowTree).to receive(:new).with(input: /tree\.json$/)
      command.call
    end

    it "returns the output path" do
      result = command.call
      expect(result).to match(/tree\.json$/)
    end
  end

  describe "with custom output" do
    let(:command) { described_class.new(org_ref, output: "custom/tree.json") }

    it "uses the custom output path" do
      expect(File).to receive(:write).with("custom/tree.json", anything)
      command.call
    end
  end

  describe "database error handling" do
    before do
      allow(PageMigration::Database).to receive(:with_connection).and_raise(PG::Error.new("Connection failed"))
    end

    it "raises PageMigration::Error" do
      command = described_class.new(org_ref)
      expect { command.call }.to raise_error(PageMigration::Error, /Database error/)
    end
  end
end
