# frozen_string_literal: true

RSpec.describe PageMigration::Generators::TextContentGenerator do
  let(:org_data) do
    {
      "name" => "Test Company",
      "reference" => "TestRef",
      "pages" => [
        {
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
    context "with French language (default)" do
      let(:generator) { described_class.new(org_data) }

      it "generates text header" do
        result = generator.generate
        expect(result).to include("Test Company")
        expect(result).to include("TestRef")
      end

      it "extracts French content" do
        result = generator.generate
        expect(result).to include("Titre")
        expect(result).to include("Contenu")
      end

      it "outputs page markers" do
        result = generator.generate
        expect(result).to include("PAGE 1/1")
      end
    end

    context "with English language" do
      let(:generator) { described_class.new(org_data, language: "en") }

      it "extracts English content" do
        result = generator.generate
        expect(result).to include("Title")
        expect(result).to include("Content")
      end

      it "falls back to French if English not available" do
        org_data["pages"].first["content_blocks"].first["content_items"].first["properties"]["subtitle"] = {"fr" => "Sous-titre"}
        result = generator.generate
        expect(result).to include("Sous-titre")
      end
    end

    context "with record data" do
      let(:org_with_records) do
        org_data.tap do |o|
          o["pages"].first["content_blocks"].first["content_items"] << {
            "properties" => {},
            "record" => {"name" => "Paris Office", "address" => "123 Street", "city" => "Paris", "country_code" => "FR"},
            "record_type" => "Office"
          }
        end
      end

      let(:generator) { described_class.new(org_with_records) }

      it "renders office record" do
        result = generator.generate
        expect(result).to include("Paris Office")
        expect(result).to include("123 Street, Paris, FR")
      end
    end

    context "deduplication" do
      let(:org_with_duplicates) do
        org_data.tap do |o|
          o["pages"].first["content_blocks"].first["content_items"] << {
            "properties" => {"title" => {"fr" => "Titre"}},
            "record" => nil,
            "record_type" => nil
          }
        end
      end

      let(:generator) { described_class.new(org_with_duplicates) }

      it "deduplicates identical content within a page" do
        result = generator.generate
        expect(result.scan("Titre").length).to eq(1)
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

      it "orders pages hierarchically" do
        result = generator.generate
        root_pos = result.index("PAGE 1/3 : /")
        child_a_pos = result.index("PAGE 2/3 : /CHILD-A")
        child_b_pos = result.index("PAGE 3/3 : /CHILD-B")

        expect(root_pos).to be < child_a_pos
        expect(child_a_pos).to be < child_b_pos
      end

      it "shows depth indicator for nested pages" do
        result = generator.generate
        expect(result).to include("(depth: 1)")
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
              "name" => "Page 1",
              "slug" => "/page1",
              "content_blocks" => [
                {"content_items" => [{"properties" => {"title" => {"fr" => "Shared Title"}}, "record" => nil, "record_type" => nil}]}
              ]
            },
            {
              "id" => 2,
              "name" => "Page 2",
              "slug" => "/page2",
              "content_blocks" => [
                {"content_items" => [{"properties" => {"title" => {"fr" => "Shared Title"}}, "record" => nil, "record_type" => nil}]}
              ]
            }
          ]
        }
      end

      let(:generator) { described_class.new(org_with_shared_content) }

      it "shows same content on multiple pages where it belongs" do
        result = generator.generate
        expect(result.scan("Shared Title").length).to eq(2)
      end
    end
  end
end
