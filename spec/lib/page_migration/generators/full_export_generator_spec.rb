# frozen_string_literal: true

RSpec.describe PageMigration::Generators::FullExportGenerator do
  let(:org_data) do
    {
      "name" => "Test Company",
      "reference" => "TestRef",
      "website" => "wttj_fr",
      "pages" => [
        {
          "id" => 1,
          "name" => "Home",
          "slug" => "/",
          "reference" => "PageRef",
          "status" => "published",
          "content_blocks" => []
        }
      ]
    }
  end
  let(:tree_data) do
    {
      "export_date" => "2024-01-01",
      "organization" => {"name" => "Test Company"},
      "page_tree" => [
        {"id" => 1, "slug" => "/", "name" => "Home", "ancestry" => nil, "status" => "published", "is_root" => true, "depth" => 0, "reference" => "PageRef", "published_at" => "2024-01-01"}
      ],
      "statistics" => {"total_pages" => 1, "root_pages" => 1, "max_depth" => 0}
    }
  end

  describe "#generate" do
    let(:generator) { described_class.new(org_data, tree_data, language: "fr") }

    it "generates header with organization info" do
      result = generator.generate
      expect(result).to include("# Test Company - Content Export (FR)")
      expect(result).to include("**Organization:** `TestRef`")
      expect(result).to include("**Website:** wttj_fr")
    end

    it "includes export date" do
      result = generator.generate
      expect(result).to include("**Export Date:** 2024-01-01")
    end

    it "includes page tree section" do
      result = generator.generate
      expect(result).to include("## 📋 Page Tree")
    end

    it "includes statistics" do
      result = generator.generate
      expect(result).to include("**Statistics:**")
      expect(result).to include("Total Pages:")
      expect(result).to include("Root Pages:")
    end

    it "includes page contents section" do
      result = generator.generate
      expect(result).to include("## 📄 Page Contents")
    end
  end

  describe "with custom_only option" do
    let(:org_with_custom) do
      org_data.merge("pages" => [
        {"id" => 1, "name" => "Home", "slug" => "/", "status" => "published", "content_blocks" => []},
        {"id" => 2, "name" => "Custom Page", "slug" => "/custom-page", "status" => "published", "content_blocks" => []}
      ])
    end
    let(:tree_with_custom) do
      tree_data.merge("page_tree" => [
        {"id" => 1, "slug" => "/", "name" => "Home", "ancestry" => nil, "status" => "published", "is_root" => true, "depth" => 0, "reference" => nil, "published_at" => nil},
        {"id" => 2, "slug" => "/custom-page", "name" => "Custom Page", "ancestry" => nil, "status" => "published", "is_root" => true, "depth" => 0, "reference" => nil, "published_at" => nil}
      ])
    end

    let(:generator) { described_class.new(org_with_custom, tree_with_custom, language: "fr", custom_only: true) }

    it "filters to only custom pages" do
      result = generator.generate
      expect(result).to include("Custom pages only")
      expect(result).to include("/custom-page")
    end
  end

  describe "SUPPORTED_LANGUAGES" do
    it "includes common languages" do
      expect(described_class::SUPPORTED_LANGUAGES).to include("fr", "en", "cs", "sk")
    end
  end
end
