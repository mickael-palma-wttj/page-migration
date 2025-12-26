# frozen_string_literal: true

RSpec.describe PageMigration::Queries::OrganizationSql do
  describe "SQL" do
    it "defines an SQL query" do
      expect(described_class::SQL).to be_a(String)
    end

    it "contains a CTE named org_pages" do
      expect(described_class::SQL).to include("WITH org_pages AS")
    end

    it "selects from organizations table" do
      expect(described_class::SQL).to include("FROM organizations")
    end

    it "joins website_organizations" do
      expect(described_class::SQL).to include("INNER JOIN website_organizations")
    end

    it "joins websites" do
      expect(described_class::SQL).to include("INNER JOIN websites")
    end

    it "filters by wttj_fr reference" do
      expect(described_class::SQL).to include("w.reference = 'wttj_fr'")
    end

    it "uses parameter placeholder for org_ref" do
      expect(described_class::SQL).to include("o.reference = $1")
    end

    it "includes polymorphic record resolution" do
      expect(described_class::SQL).to include("CASE")
      expect(described_class::SQL).to include("Cms::Image")
      expect(described_class::SQL).to include("Cms::Video")
      expect(described_class::SQL).to include("Office")
    end
  end
end
