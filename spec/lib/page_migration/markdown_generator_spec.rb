# frozen_string_literal: true

RSpec.describe PageMigration::MarkdownGenerator do
  let(:org_data) do
    {
      "name" => "Test Company",
      "reference" => "TestRef",
      "website" => "https://example.com",
      "created_at" => "2024-01-01",
      "updated_at" => "2024-01-02",
      "pages" => [
        {
          "id" => 1,
          "name" => "About",
          "slug" => "/about",
          "reference" => "PageRef1",
          "status" => "published",
          "position" => 0,
          "created_at" => "2024-01-01",
          "content_blocks" => [
            {
              "id" => 10,
              "kind" => "text",
              "position" => 0,
              "created_at" => "2024-01-01",
              "content_items" => [
                {
                  "id" => 100,
                  "kind" => "paragraph",
                  "record_type" => nil,
                  "position" => 0,
                  "properties" => {"title" => "Hello"}
                }
              ]
            }
          ]
        }
      ]
    }
  end

  describe "#generate" do
    subject(:generator) { described_class.new(org_data) }

    it "generates markdown with organization header" do
      result = generator.generate
      expect(result).to include("# Test Company")
      expect(result).to include("**Organization Reference:** `TestRef`")
      expect(result).to include("**Website:** https://example.com")
    end

    it "includes page information" do
      result = generator.generate
      expect(result).to include("## Page 1: About")
      expect(result).to include("**Slug:** `/about`")
      expect(result).to include("**Status:** `published`")
    end

    it "includes block information" do
      result = generator.generate
      expect(result).to include("### Block 1: text")
    end

    it "includes item information" do
      result = generator.generate
      expect(result).to include("#### Item 1: paragraph")
    end
  end

  describe "with empty pages" do
    let(:org_without_pages) do
      org_data.merge("pages" => nil)
    end

    it "handles nil pages gracefully" do
      generator = described_class.new(org_without_pages)
      result = generator.generate
      expect(result).to include("# Test Company")
      expect(result).not_to include("## Page")
    end
  end

  describe "with nil reference" do
    let(:page_without_ref) do
      org_data.tap { |o| o["pages"].first["reference"] = nil }
    end

    it "formats nil reference as null" do
      generator = described_class.new(page_without_ref)
      result = generator.generate
      expect(result).to include("**Reference:** null")
    end
  end
end
