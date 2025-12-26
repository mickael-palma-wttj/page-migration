# frozen_string_literal: true

RSpec.describe PageMigration::Renderers::ContentRenderer do
  let(:test_class) do
    Class.new do
      include PageMigration::Renderers::ContentRenderer
    end
  end
  let(:renderer) { test_class.new }

  describe "#build_pages_index" do
    let(:org) do
      {
        "pages" => [
          {"id" => 1, "name" => "Page 1"},
          {"id" => 2, "name" => "Page 2"}
        ]
      }
    end

    it "builds a hash indexed by page id" do
      result = renderer.build_pages_index(org)
      expect(result[1]["name"]).to eq("Page 1")
      expect(result[2]["name"]).to eq("Page 2")
    end

    it "handles nil pages" do
      expect(renderer.build_pages_index({})).to eq({})
    end
  end

  describe "#build_tree_index" do
    let(:tree) do
      {
        "page_tree" => [
          {"id" => 1, "slug" => "/"},
          {"id" => 2, "slug" => "/about"}
        ]
      }
    end

    it "builds a hash indexed by page id" do
      result = renderer.build_tree_index(tree)
      expect(result[1]["slug"]).to eq("/")
      expect(result[2]["slug"]).to eq("/about")
    end
  end

  describe "#find_children" do
    let(:tree) do
      {
        "page_tree" => [
          {"id" => 1, "ancestry" => nil},
          {"id" => 2, "ancestry" => "1"},
          {"id" => 3, "ancestry" => "1"},
          {"id" => 4, "ancestry" => "2"}
        ]
      }
    end

    it "finds direct children by parent id" do
      children = renderer.find_children(tree, 1)
      expect(children.length).to eq(2)
      expect(children.map { |c| c["id"] }).to contain_exactly(2, 3)
    end

    it "returns empty array for pages with no children" do
      children = renderer.find_children(tree, 3)
      expect(children).to eq([])
    end
  end

  describe "#render_property" do
    it "renders localized value for matching language" do
      result = renderer.render_property("title", {"fr" => "Bonjour"}, "fr")
      expect(result).to include("**Title:** Bonjour")
    end

    it "returns nil for settings key" do
      expect(renderer.render_property("settings", {}, "fr")).to be_nil
    end

    it "returns nil for nil value" do
      expect(renderer.render_property("title", nil, "fr")).to be_nil
    end

    it "returns nil for empty localized value" do
      expect(renderer.render_property("title", {"fr" => ""}, "fr")).to be_nil
    end

    it "renders non-hash values directly" do
      result = renderer.render_property("count", 42, "fr")
      expect(result).to include("**Count:** 42")
    end

    it "renders multiline body values with newlines" do
      result = renderer.render_property("body", {"fr" => "Line 1\nLine 2"}, "fr")
      expect(result).to include("Line 1\nLine 2")
    end
  end

  describe "#render_localized_value" do
    it "renders short values inline" do
      result = renderer.render_localized_value("title", "Hello")
      expect(result).to eq("- **Title:** Hello\n")
    end

    it "renders long body values with newlines" do
      long_text = "a" * 150
      result = renderer.render_localized_value("body", long_text)
      expect(result).to start_with("\n")
    end

    it "renders multiline values with proper formatting" do
      result = renderer.render_localized_value("title", "Line1\nLine2")
      expect(result).to include("**Title:**")
    end
  end
end
