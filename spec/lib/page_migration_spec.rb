# frozen_string_literal: true

RSpec.describe PageMigration::Errors do
  describe PageMigration::Errors::Base do
    it "is a StandardError" do
      expect(described_class).to be < StandardError
    end

    it "can be raised with a message" do
      expect { raise described_class, "Test error" }.to raise_error(
        described_class,
        "Test error"
      )
    end

    it "is aliased as PageMigration::Error" do
      expect(PageMigration::Error).to eq(described_class)
    end
  end

  describe PageMigration::Errors::DustApiError do
    it "is a PageMigration::Errors::Base" do
      expect(described_class).to be < PageMigration::Errors::Base
    end

    it "stores status and response_body" do
      error = described_class.new("API failed", status: 500, response_body: '{"error": "Internal"}')

      expect(error.message).to eq("API failed")
      expect(error.status).to eq(500)
      expect(error.response_body).to eq('{"error": "Internal"}')
    end

    it "is aliased as PageMigration::DustApiError" do
      expect(PageMigration::DustApiError).to eq(described_class)
    end
  end

  describe PageMigration::Errors::ParseError do
    it "is a PageMigration::Errors::Base" do
      expect(described_class).to be < PageMigration::Errors::Base
    end

    it "stores file_path" do
      error = described_class.new("Invalid JSON", file_path: "/path/to/file.json")

      expect(error.message).to eq("Invalid JSON")
      expect(error.file_path).to eq("/path/to/file.json")
    end

    it "is aliased as PageMigration::ParseError" do
      expect(PageMigration::ParseError).to eq(described_class)
    end
  end

  describe PageMigration::Errors::DatabaseError do
    it "is a PageMigration::Errors::Base" do
      expect(described_class).to be < PageMigration::Errors::Base
    end

    it "is aliased as PageMigration::DatabaseError" do
      expect(PageMigration::DatabaseError).to eq(described_class)
    end
  end

  describe PageMigration::Errors::FileNotFoundError do
    it "is a PageMigration::Errors::Base" do
      expect(described_class).to be < PageMigration::Errors::Base
    end

    it "stores file_path" do
      error = described_class.new("File missing", file_path: "/missing/file.txt")

      expect(error.message).to eq("File missing")
      expect(error.file_path).to eq("/missing/file.txt")
    end

    it "is aliased as PageMigration::FileNotFoundError" do
      expect(PageMigration::FileNotFoundError).to eq(described_class)
    end
  end

  describe PageMigration::Errors::ValidationError do
    it "is a PageMigration::Errors::Base" do
      expect(described_class).to be < PageMigration::Errors::Base
    end

    it "is aliased as PageMigration::ValidationError" do
      expect(PageMigration::ValidationError).to eq(described_class)
    end
  end
end
