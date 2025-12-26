# frozen_string_literal: true

RSpec.describe PageMigration::Queries::PageTreeSql do
  describe "SQL" do
    it "defines an SQL query" do
      expect(described_class::SQL).to be_a(String)
    end

    it "contains a CTE named page_hierarchy" do
      expect(described_class::SQL).to include("WITH page_hierarchy AS")
    end

    it "selects from cms_pages table" do
      expect(described_class::SQL).to include("FROM cms_pages")
    end

    it "joins website_organizations" do
      expect(described_class::SQL).to include("INNER JOIN website_organizations")
    end

    it "calculates depth from ancestry" do
      expect(described_class::SQL).to include("ARRAY_LENGTH")
      expect(described_class::SQL).to include("STRING_TO_ARRAY")
    end

    it "filters by wttj_fr reference" do
      expect(described_class::SQL).to include("w.reference = 'wttj_fr'")
    end

    it "uses parameter placeholder for org_ref" do
      expect(described_class::SQL).to include("o.reference = $1")
    end

    it "includes statistics" do
      expect(described_class::SQL).to include("'statistics'")
      expect(described_class::SQL).to include("total_pages")
      expect(described_class::SQL).to include("root_pages")
      expect(described_class::SQL).to include("max_depth")
    end
  end
end
