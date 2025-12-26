# frozen_string_literal: true

require "tempfile"

RSpec.describe PageMigration::Commands::ShowTree do
  let(:tree_data) do
    {
      "organization" => {"name" => "Test Company", "reference" => "TestRef", "website" => "wttj_fr"},
      "export_date" => "2024-01-01",
      "page_tree" => [
        {"id" => 1, "slug" => "/", "name" => "Home", "ancestry" => nil, "status" => "published", "position" => 0, "depth" => 0, "is_root" => true, "reference" => "Ref1", "published_at" => "2024-01-01"},
        {"id" => 2, "slug" => "/about", "name" => "About", "ancestry" => "1", "status" => "draft", "position" => 0, "depth" => 1, "is_root" => false, "reference" => nil, "published_at" => nil}
      ]
    }
  end
  let(:temp_file) { Tempfile.new(["tree", ".json"]) }

  before do
    temp_file.write(tree_data.to_json)
    temp_file.close
  end

  after do
    temp_file.unlink
  end

  describe "#call" do
    let(:command) { described_class.new(input: temp_file.path) }

    it "displays the tree header" do
      expect { command.call }.to output(/PAGE TREE VIEW.*Test Company/).to_stdout
    end

    it "displays page hierarchy" do
      expect { command.call }.to output(/PAGE HIERARCHY/).to_stdout
    end

    it "displays statistics" do
      expect { command.call }.to output(/STATISTICS/).to_stdout
    end

    it "shows total pages" do
      expect { command.call }.to output(/Total Pages: 2/).to_stdout
    end

    it "shows root pages count" do
      expect { command.call }.to output(/Root Pages: 1/).to_stdout
    end

    it "shows child pages count" do
      expect { command.call }.to output(/Child Pages: 1/).to_stdout
    end

    it "shows published count" do
      expect { command.call }.to output(/Published: 1/).to_stdout
    end

    it "shows draft count" do
      expect { command.call }.to output(/Draft: 1/).to_stdout
    end
  end

  describe "with missing file" do
    let(:command) { described_class.new(input: "/nonexistent/file.json") }

    it "raises an error" do
      expect { command.call }.to raise_error(PageMigration::Errors::Base, /File not found/)
    end
  end

  describe "DEFAULT_INPUT" do
    it "has a default input path" do
      expect(described_class::DEFAULT_INPUT).to eq("query_result/page_tree.json")
    end
  end
end
