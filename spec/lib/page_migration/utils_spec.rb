# frozen_string_literal: true

RSpec.describe PageMigration::Utils do
  describe ".sanitize_filename" do
    it "converts spaces to underscores" do
      expect(described_class.sanitize_filename("Hello World")).to eq("hello_world")
    end

    it "downcases the string" do
      expect(described_class.sanitize_filename("HelloWorld")).to eq("helloworld")
    end

    it "removes special characters and replaces with underscore" do
      expect(described_class.sanitize_filename("Hello@World!")).to eq("hello_world")
    end

    it "removes leading and trailing underscores" do
      expect(described_class.sanitize_filename("_hello_")).to eq("hello")
    end

    it "replaces multiple non-alphanumeric chars with single underscore" do
      expect(described_class.sanitize_filename("Hello   World")).to eq("hello_world")
    end

    it "handles empty string" do
      expect(described_class.sanitize_filename("")).to eq("")
    end

    it "handles company names with special chars" do
      expect(described_class.sanitize_filename("Welcome to the Jungle")).to eq("welcome_to_the_jungle")
    end
  end

  describe ".empty_value?" do
    it "returns true for nil" do
      expect(described_class.empty_value?(nil)).to be true
    end

    it "returns true for empty string" do
      expect(described_class.empty_value?("")).to be true
    end

    it "returns true for whitespace-only string" do
      expect(described_class.empty_value?("   ")).to be true
    end

    it "returns false for non-empty string" do
      expect(described_class.empty_value?("hello")).to be false
    end

    it "returns false for numbers" do
      expect(described_class.empty_value?(0)).to be false
    end
  end
end
