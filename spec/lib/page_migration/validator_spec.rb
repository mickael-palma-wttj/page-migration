# frozen_string_literal: true

RSpec.describe PageMigration::Validator do
  describe ".validate_org_ref!" do
    context "with valid org_ref" do
      it "returns the org_ref for alphanumeric 7 chars" do
        expect(described_class.validate_org_ref!("Pg4eV6k")).to eq("Pg4eV6k")
      end

      it "returns the org_ref for 5 chars" do
        expect(described_class.validate_org_ref!("Ab123")).to eq("Ab123")
      end

      it "returns the org_ref for 10 chars" do
        expect(described_class.validate_org_ref!("Abcd123456")).to eq("Abcd123456")
      end
    end

    context "with invalid org_ref" do
      it "raises ValidationError for nil" do
        expect { described_class.validate_org_ref!(nil) }
          .to raise_error(PageMigration::ValidationError, /required/)
      end

      it "raises ValidationError for empty string" do
        expect { described_class.validate_org_ref!("") }
          .to raise_error(PageMigration::ValidationError, /required/)
      end

      it "raises ValidationError for too short (4 chars)" do
        expect { described_class.validate_org_ref!("Ab12") }
          .to raise_error(PageMigration::ValidationError, /Invalid organization reference/)
      end

      it "raises ValidationError for too long (11 chars)" do
        expect { described_class.validate_org_ref!("Abcd1234567") }
          .to raise_error(PageMigration::ValidationError, /Invalid organization reference/)
      end

      it "raises ValidationError for special characters" do
        expect { described_class.validate_org_ref!("Pg4e-V6") }
          .to raise_error(PageMigration::ValidationError, /Invalid organization reference/)
      end
    end
  end

  describe ".validate_language!" do
    context "with valid language" do
      %w[fr en cs de es it pt].each do |lang|
        it "returns #{lang}" do
          expect(described_class.validate_language!(lang)).to eq(lang)
        end
      end
    end

    context "with nil" do
      it "returns default 'fr'" do
        expect(described_class.validate_language!(nil)).to eq("fr")
      end
    end

    context "with unsupported language" do
      it "raises ValidationError" do
        expect { described_class.validate_language!("zh") }
          .to raise_error(PageMigration::ValidationError, /Unsupported language: zh/)
      end
    end
  end

  describe ".validate_languages!" do
    context "with valid languages" do
      it "returns the languages array" do
        expect(described_class.validate_languages!(%w[fr en])).to eq(%w[fr en])
      end

      it "accepts all supported languages" do
        expect(described_class.validate_languages!(%w[fr en cs de es it pt]))
          .to eq(%w[fr en cs de es it pt])
      end
    end

    context "with nil or empty" do
      it "returns default [fr, en] for nil" do
        expect(described_class.validate_languages!(nil)).to eq(%w[fr en])
      end

      it "returns default [fr, en] for empty array" do
        expect(described_class.validate_languages!([])).to eq(%w[fr en])
      end
    end

    context "with unsupported language" do
      it "raises ValidationError listing invalid languages" do
        expect { described_class.validate_languages!(%w[fr zh jp]) }
          .to raise_error(PageMigration::ValidationError, /Unsupported languages: zh, jp/)
      end
    end
  end

  describe ".validate_format!" do
    context "with valid format" do
      it "returns 'json'" do
        expect(described_class.validate_format!("json")).to eq("json")
      end

      it "returns 'text'" do
        expect(described_class.validate_format!("text")).to eq("text")
      end
    end

    context "with nil" do
      it "returns default 'json'" do
        expect(described_class.validate_format!(nil)).to eq("json")
      end
    end

    context "with unsupported format" do
      it "raises ValidationError" do
        expect { described_class.validate_format!("xml") }
          .to raise_error(PageMigration::ValidationError, /Unsupported format: xml/)
      end
    end
  end

  describe ".validate_file_exists!" do
    context "when file exists" do
      it "returns the path" do
        path = __FILE__
        expect(described_class.validate_file_exists!(path)).to eq(path)
      end
    end

    context "when file does not exist" do
      it "raises FileNotFoundError" do
        expect { described_class.validate_file_exists!("/nonexistent/file.txt") }
          .to raise_error(PageMigration::FileNotFoundError, /File not found/)
      end
    end
  end

  describe ".validate_directory_exists!" do
    context "when directory exists" do
      it "returns the path" do
        path = File.dirname(__FILE__)
        expect(described_class.validate_directory_exists!(path)).to eq(path)
      end
    end

    context "when directory does not exist" do
      it "raises FileNotFoundError" do
        expect { described_class.validate_directory_exists!("/nonexistent/dir") }
          .to raise_error(PageMigration::FileNotFoundError, /Directory not found/)
      end
    end
  end
end
