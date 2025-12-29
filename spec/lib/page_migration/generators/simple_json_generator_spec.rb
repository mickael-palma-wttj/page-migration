# frozen_string_literal: true

RSpec.describe PageMigration::Generators::SimpleJsonGenerator do
  let(:org_data) do
    {
      "name" => "Test Company",
      "reference" => "TestRef",
      "pages" => [
        {
          "id" => 1,
          "name" => "About",
          "slug" => "/about",
          "content_blocks" => [
            {
              "content_items" => [
                {
                  "properties" => {
                    "title" => {"fr" => "Titre", "en" => "Title"},
                    "body" => {"fr" => "Contenu", "en" => "Content"}
                  },
                  "record" => nil,
                  "record_type" => nil
                }
              ]
            }
          ]
        }
      ]
    }
  end

  describe "#generate" do
    let(:generator) { described_class.new(org_data) }

    it "returns a hash with organization info" do
      result = generator.generate
      expect(result[:organization][:reference]).to eq("TestRef")
      expect(result[:organization][:name]).to eq("Test Company")
    end

    it "includes language" do
      result = generator.generate
      expect(result[:language]).to eq("fr")
    end

    it "includes exported_at timestamp" do
      result = generator.generate
      expect(result[:exported_at]).to match(/^\d{4}-\d{2}-\d{2}T/)
    end

    it "includes pages array with order" do
      result = generator.generate
      expect(result[:pages]).to be_an(Array)
      expect(result[:pages].first[:order]).to eq(0)
    end

    it "includes page slug and depth" do
      result = generator.generate
      page = result[:pages].first
      expect(page[:slug]).to eq("/about")
      expect(page[:depth]).to eq(0)
    end

    it "extracts content as array of strings" do
      result = generator.generate
      page = result[:pages].first
      expect(page[:content]).to include("Titre")
      expect(page[:content]).to include("Contenu")
    end
  end

  describe "#to_json" do
    let(:generator) { described_class.new(org_data) }

    it "returns valid JSON string" do
      json = generator.to_json
      parsed = JSON.parse(json)
      expect(parsed["organization"]["reference"]).to eq("TestRef")
    end
  end

  context "with tree data for hierarchical ordering" do
    let(:org_with_multiple_pages) do
      {
        "name" => "Test Company",
        "reference" => "TestRef",
        "pages" => [
          {"id" => 1, "name" => "Root", "slug" => "/", "content_blocks" => []},
          {"id" => 2, "name" => "Child A", "slug" => "/child-a", "content_blocks" => []},
          {"id" => 3, "name" => "Child B", "slug" => "/child-b", "content_blocks" => []}
        ]
      }
    end

    let(:tree_data) do
      {
        "page_tree" => [
          {"id" => 1, "slug" => "/", "name" => "Root", "is_root" => true, "depth" => 0, "ancestry" => nil, "position" => 0},
          {"id" => 2, "slug" => "/child-a", "name" => "Child A", "is_root" => false, "depth" => 1, "ancestry" => "1", "position" => 0},
          {"id" => 3, "slug" => "/child-b", "name" => "Child B", "is_root" => false, "depth" => 1, "ancestry" => "1", "position" => 1}
        ]
      }
    end

    let(:generator) { described_class.new(org_with_multiple_pages, tree_data: tree_data) }

    it "orders pages hierarchically with correct order values" do
      result = generator.generate
      pages = result[:pages]

      expect(pages[0][:slug]).to eq("/")
      expect(pages[0][:order]).to eq(0)
      expect(pages[0][:depth]).to eq(0)

      expect(pages[1][:slug]).to eq("/child-a")
      expect(pages[1][:order]).to eq(1)
      expect(pages[1][:depth]).to eq(1)

      expect(pages[2][:slug]).to eq("/child-b")
      expect(pages[2][:order]).to eq(2)
      expect(pages[2][:depth]).to eq(1)
    end
  end

  context "with English language" do
    let(:generator) { described_class.new(org_data, language: "en") }

    it "extracts English content" do
      result = generator.generate
      page = result[:pages].first
      expect(page[:content]).to include("Title")
      expect(page[:content]).to include("Content")
    end

    it "sets language to en" do
      result = generator.generate
      expect(result[:language]).to eq("en")
    end
  end

  context "per-page deduplication" do
    let(:org_with_shared_content) do
      {
        "name" => "Test Company",
        "reference" => "TestRef",
        "pages" => [
          {
            "id" => 1,
            "slug" => "/page1",
            "content_blocks" => [
              {"content_items" => [{"properties" => {"title" => {"fr" => "Shared"}}, "record" => nil, "record_type" => nil}]}
            ]
          },
          {
            "id" => 2,
            "slug" => "/page2",
            "content_blocks" => [
              {"content_items" => [{"properties" => {"title" => {"fr" => "Shared"}}, "record" => nil, "record_type" => nil}]}
            ]
          }
        ]
      }
    end

    let(:generator) { described_class.new(org_with_shared_content) }

    it "shows same content on multiple pages" do
      result = generator.generate
      expect(result[:pages][0][:content]).to include("Shared")
      expect(result[:pages][1][:content]).to include("Shared")
    end
  end
end
