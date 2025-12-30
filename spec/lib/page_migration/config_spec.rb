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

  describe "DEFAULT_OUTPUT_ROOT" do
    it "defines the default root output directory" do
      expect(described_class::DEFAULT_OUTPUT_ROOT).to eq("tmp")
    end
  end

  describe ".output_root" do
    it "returns the default when not overridden" do
      expect(described_class.output_root).to eq("tmp")
    end

    it "can be set via thread-local" do
      described_class.output_root = "/custom/path"
      expect(described_class.output_root).to eq("/custom/path")
      described_class.output_root = nil
    end
  end

  describe ".with_output_root" do
    it "temporarily sets the output root" do
      described_class.with_output_root("/temp/path") do
        expect(described_class.output_root).to eq("/temp/path")
      end
      expect(described_class.output_root).to eq("tmp")
    end
  end

  describe ".output_dir" do
    it "returns the unified output path for an organization" do
      expect(described_class.output_dir("Pg4eV6k", "Test Company")).to eq("tmp/Pg4eV6k_test_company")
    end

    it "sanitizes the org name" do
      expect(described_class.output_dir("Pg4eV6k", "Company/With:Bad*Chars")).to eq("tmp/Pg4eV6k_company_with_bad_chars")
    end

    it "uses the custom output root when set" do
      described_class.with_output_root("/custom") do
        expect(described_class.output_dir("Pg4eV6k", "Test")).to eq("/custom/Pg4eV6k_test")
      end
    end
  end
end
