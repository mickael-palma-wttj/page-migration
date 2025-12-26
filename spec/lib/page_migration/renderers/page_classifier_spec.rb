# frozen_string_literal: true

RSpec.describe PageMigration::Renderers::PageClassifier do
  describe ".classify" do
    it "returns 'profil' for root slug" do
      expect(described_class.classify("/")).to eq("profil")
    end

    it "returns 'jobs' for job-related slugs" do
      expect(described_class.classify("/jobs")).to eq("jobs")
      expect(described_class.classify("/our-jobs")).to eq("jobs")
      expect(described_class.classify("/JOB-offers")).to eq("jobs")
    end

    it "returns 'team' for team-related slugs" do
      expect(described_class.classify("/team")).to eq("team")
      expect(described_class.classify("/our-team")).to eq("team")
      expect(described_class.classify("/equipe")).to eq("team")
    end

    it "returns 'tech' for tech-related slugs" do
      expect(described_class.classify("/tech")).to eq("tech")
      expect(described_class.classify("/tech-stack")).to eq("tech")
    end

    it "returns 'culture' for culture-related slugs" do
      expect(described_class.classify("/culture")).to eq("culture")
      expect(described_class.classify("/our-culture")).to eq("culture")
    end

    it "returns 'benefits' for benefits-related slugs" do
      expect(described_class.classify("/plus")).to eq("benefits")
      expect(described_class.classify("/les-plus")).to eq("benefits")
    end

    it "returns 'office_and_remote' for office/remote slugs" do
      expect(described_class.classify("/bureau")).to eq("office_and_remote")
      expect(described_class.classify("/office")).to eq("office_and_remote")
      expect(described_class.classify("/teletravail")).to eq("office_and_remote")
      expect(described_class.classify("/remote")).to eq("office_and_remote")
    end

    it "returns 'event' for event-related slugs" do
      expect(described_class.classify("/meeting")).to eq("event")
    end

    it "returns 'featured' for featured-related slugs" do
      expect(described_class.classify("/featured")).to eq("featured")
    end

    it "returns 'custom' for unmatched slugs" do
      expect(described_class.classify("/about-us")).to eq("custom")
      expect(described_class.classify("/contact")).to eq("custom")
    end

    it "returns 'custom' for nil slug" do
      expect(described_class.classify(nil)).to eq("custom")
    end
  end

  describe ".custom?" do
    it "returns true for custom pages" do
      expect(described_class.custom?("/about-us")).to be true
    end

    it "returns false for standard pages" do
      expect(described_class.custom?("/")).to be false
      expect(described_class.custom?("/jobs")).to be false
    end
  end

  describe ".standard?" do
    it "returns true for standard pages" do
      expect(described_class.standard?("/")).to be true
      expect(described_class.standard?("/jobs")).to be true
    end

    it "returns false for custom pages" do
      expect(described_class.standard?("/about-us")).to be false
    end
  end
end
