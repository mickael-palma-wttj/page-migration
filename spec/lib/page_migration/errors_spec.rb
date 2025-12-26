# frozen_string_literal: true

RSpec.describe PageMigration::Errors do
  describe PageMigration::Errors::Base do
    it "inherits from StandardError" do
      expect(described_class.superclass).to eq(StandardError)
    end

    it "can be raised with a message" do
      expect { raise described_class, "test error" }
        .to raise_error(described_class, "test error")
    end
  end

  describe PageMigration::Errors::DustApiError do
    it "stores status and response_body" do
      error = described_class.new("API failed", status: 500, response_body: '{"error": "Internal"}')

      expect(error.message).to eq("API failed")
      expect(error.status).to eq(500)
      expect(error.response_body).to eq('{"error": "Internal"}')
    end

    it "works without optional attributes" do
      error = described_class.new("API failed")

      expect(error.message).to eq("API failed")
      expect(error.status).to be_nil
      expect(error.response_body).to be_nil
    end
  end

  describe PageMigration::Errors::ParseError do
    it "stores file_path" do
      error = described_class.new("Parse failed", file_path: "/path/to/file.json")

      expect(error.message).to eq("Parse failed")
      expect(error.file_path).to eq("/path/to/file.json")
    end

    it "works without file_path" do
      error = described_class.new("Parse failed")

      expect(error.message).to eq("Parse failed")
      expect(error.file_path).to be_nil
    end
  end

  describe PageMigration::Errors::DatabaseError do
    it "inherits from Base" do
      expect(described_class.superclass).to eq(PageMigration::Errors::Base)
    end
  end

  describe PageMigration::Errors::FileNotFoundError do
    it "stores file_path" do
      error = described_class.new("File not found", file_path: "/missing/file.txt")

      expect(error.message).to eq("File not found")
      expect(error.file_path).to eq("/missing/file.txt")
    end
  end

  describe PageMigration::Errors::ValidationError do
    it "inherits from Base" do
      expect(described_class.superclass).to eq(PageMigration::Errors::Base)
    end
  end

  describe "short aliases" do
    it "aliases Error to Errors::Base" do
      expect(PageMigration::Error).to eq(PageMigration::Errors::Base)
    end

    it "aliases DustApiError to Errors::DustApiError" do
      expect(PageMigration::DustApiError).to eq(PageMigration::Errors::DustApiError)
    end

    it "aliases ParseError to Errors::ParseError" do
      expect(PageMigration::ParseError).to eq(PageMigration::Errors::ParseError)
    end

    it "aliases DatabaseError to Errors::DatabaseError" do
      expect(PageMigration::DatabaseError).to eq(PageMigration::Errors::DatabaseError)
    end

    it "aliases FileNotFoundError to Errors::FileNotFoundError" do
      expect(PageMigration::FileNotFoundError).to eq(PageMigration::Errors::FileNotFoundError)
    end

    it "aliases ValidationError to Errors::ValidationError" do
      expect(PageMigration::ValidationError).to eq(PageMigration::Errors::ValidationError)
    end
  end
end
