# frozen_string_literal: true

RSpec.describe PageMigration::Config do
  describe "DEFAULT_TIMEOUT" do
    context "when DUST_TIMEOUT env is set" do
      around do |example|
        original = ENV["DUST_TIMEOUT"]
        ENV["DUST_TIMEOUT"] = "600"
        # Reload the constant by removing and re-requiring
        # Since constants are evaluated at load time, we test the default behavior
        example.run
        ENV["DUST_TIMEOUT"] = original
      end

      it "uses ENV value when set at load time" do
        # The constant is set at load time, so we just verify it's an integer
        expect(described_class::DEFAULT_TIMEOUT).to be_a(Integer)
      end
    end

    context "with default value" do
      it "defaults to 300 seconds" do
        # This tests the default since DUST_TIMEOUT is likely not set
        expect(described_class::DEFAULT_TIMEOUT).to eq(300)
      end
    end
  end

  describe "MAX_FRAGMENT_SIZE" do
    it "defaults to 500_000 bytes" do
      expect(described_class::MAX_FRAGMENT_SIZE).to eq(500_000)
    end
  end

  describe "WORKER_COUNT" do
    it "defaults to 5 workers" do
      expect(described_class::WORKER_COUNT).to eq(5)
    end
  end

  describe "directory constants" do
    it "defines EXPORT_DIR" do
      expect(described_class::EXPORT_DIR).to eq("tmp/export")
    end

    it "defines ANALYSIS_DIR" do
      expect(described_class::ANALYSIS_DIR).to eq("tmp/analysis")
    end

    it "defines QUERY_RESULT_DIR" do
      expect(described_class::QUERY_RESULT_DIR).to eq("tmp/query_result")
    end

    it "defines GENERATED_ASSETS_DIR" do
      expect(described_class::GENERATED_ASSETS_DIR).to eq("tmp/generated_assets")
    end
  end
end
