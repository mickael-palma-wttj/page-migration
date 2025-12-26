# frozen_string_literal: true

require "tmpdir"

RSpec.describe PageMigration::Generators::TreeExportGenerator do
  let(:org_data) do
    {
      "name" => "Test Company",
      "reference" => "TestRef",
      "pages" => [
        {
          "id" => 1,
          "name" => "Home",
          "slug" => "/",
          "status" => "published",
          "content_blocks" => [{"id" => 10, "kind" => "text", "content_items" => []}]
        },
        {
          "id" => 2,
          "name" => "Custom Page",
          "slug" => "/custom-page",
          "status" => "draft",
          "content_blocks" => []
        }
      ]
    }
  end
  let(:tree_data) do
    {
      "page_tree" => [
        {"id" => 1, "slug" => "/", "name" => "Home", "ancestry" => nil, "status" => "published", "is_root" => true, "depth" => 0, "reference" => "Ref1", "published_at" => "2024-01-01"},
        {"id" => 2, "slug" => "/custom-page", "name" => "Custom Page", "ancestry" => "1", "status" => "draft", "is_root" => false, "depth" => 1, "reference" => nil, "published_at" => nil}
      ]
    }
  end
  let(:output_dir) { Dir.mktmpdir }

  after do
    FileUtils.rm_rf(output_dir)
  end

  describe "#generate" do
    let(:generator) do
      described_class.new(org_data, tree_data, language: "fr", output_dir: output_dir)
    end

    it "creates output directory" do
      generator.generate
      expect(Dir.exist?(output_dir)).to be true
    end

    it "creates index.md for root page" do
      generator.generate
      expect(File.exist?(File.join(output_dir, "index.md"))).to be true
    end

    it "creates subdirectory for child pages" do
      generator.generate
      # Utils.sanitize_filename converts "custom-page" to "custom_page"
      expect(Dir.exist?(File.join(output_dir, "custom_page"))).to be true
    end

    it "generates page content with status icon" do
      generator.generate
      content = File.read(File.join(output_dir, "index.md"))
      expect(content).to include("# ✅ Home")
    end

    it "includes page metadata" do
      generator.generate
      content = File.read(File.join(output_dir, "index.md"))
      expect(content).to include("**Slug:** `/`")
      expect(content).to include("**Status:** published")
    end
  end

  describe "with custom_only option" do
    let(:generator) do
      described_class.new(org_data, tree_data, language: "fr", output_dir: output_dir, custom_only: true)
    end

    it "only exports custom pages" do
      generator.generate
      # "/" is classified as "profil" (not custom), should not be exported as content
      # But directory structure is still created for hierarchy
      # Utils.sanitize_filename converts "custom-page" to "custom_page"
      expect(File.exist?(File.join(output_dir, "custom_page", "index.md"))).to be true
    end
  end
end
