# frozen_string_literal: true

RSpec.describe PageMigration::Renderers::TreeRenderer do
  let(:test_class) do
    Class.new do
      include PageMigration::Renderers::TreeRenderer
    end
  end
  let(:renderer) { test_class.new }

  describe "#tree_connector" do
    it "returns last connector when is_last is true" do
      expect(renderer.tree_connector(true)).to eq("└── ")
    end

    it "returns middle connector when is_last is false" do
      expect(renderer.tree_connector(false)).to eq("├── ")
    end
  end

  describe "#tree_prefix" do
    it "adds last prefix when is_last is true" do
      expect(renderer.tree_prefix("", true)).to eq("    ")
    end

    it "adds middle prefix when is_last is false" do
      expect(renderer.tree_prefix("", false)).to eq("│   ")
    end

    it "appends to existing prefix" do
      expect(renderer.tree_prefix("│   ", true)).to eq("│       ")
    end
  end

  describe "#status_icon" do
    it "returns checkmark for published status" do
      expect(renderer.status_icon("published")).to eq("✅")
    end

    it "returns cross for draft status" do
      expect(renderer.status_icon("draft")).to eq("❌")
    end

    it "returns cross for any non-published status" do
      expect(renderer.status_icon("pending")).to eq("❌")
      expect(renderer.status_icon(nil)).to eq("❌")
    end
  end

  describe "constants" do
    it "defines CONNECTOR_LAST" do
      expect(described_class::CONNECTOR_LAST).to eq("└── ")
    end

    it "defines CONNECTOR_MIDDLE" do
      expect(described_class::CONNECTOR_MIDDLE).to eq("├── ")
    end

    it "defines PREFIX_LAST" do
      expect(described_class::PREFIX_LAST).to eq("    ")
    end

    it "defines PREFIX_MIDDLE" do
      expect(described_class::PREFIX_MIDDLE).to eq("│   ")
    end

    it "defines STATUS_PUBLISHED" do
      expect(described_class::STATUS_PUBLISHED).to eq("✅")
    end

    it "defines STATUS_DRAFT" do
      expect(described_class::STATUS_DRAFT).to eq("❌")
    end
  end
end
