# frozen_string_literal: true

RSpec.describe PageMigration::Support::FileDiscovery do
  let(:output_root) { PageMigration::Config::OUTPUT_ROOT }

  describe ".find_query_json" do
    context "when file exists" do
      before do
        allow(Dir).to receive(:glob).and_return(["tmp/Pg4eV6k_company/query.json"])
      end

      it "returns the first matching file" do
        expect(described_class.find_query_json("Pg4eV6k")).to eq("tmp/Pg4eV6k_company/query.json")
      end
    end

    context "when no file exists" do
      before do
        allow(Dir).to receive(:glob).and_return([])
      end

      it "returns nil" do
        expect(described_class.find_query_json("NonExistent")).to be_nil
      end
    end
  end

  describe ".find_query_json!" do
    context "when file exists" do
      before do
        allow(described_class).to receive(:find_query_json).and_return("path/to/query.json")
      end

      it "returns the path" do
        expect(described_class.find_query_json!("Pg4eV6k")).to eq("path/to/query.json")
      end
    end

    context "when no file exists" do
      before do
        allow(described_class).to receive(:find_query_json).and_return(nil)
      end

      it "raises FileNotFoundError" do
        expect { described_class.find_query_json!("NonExistent") }
          .to raise_error(PageMigration::FileNotFoundError, /No query.json for NonExistent/)
      end
    end
  end

  describe ".find_latest_query_json" do
    context "when files exist" do
      let(:files) { ["tmp/org1_company/query.json", "tmp/org2_company/query.json"] }

      before do
        allow(Dir).to receive(:glob).and_return(files)
        allow(File).to receive(:mtime).with(files[0]).and_return(Time.now - 100)
        allow(File).to receive(:mtime).with(files[1]).and_return(Time.now)
      end

      it "returns the most recently modified file" do
        expect(described_class.find_latest_query_json).to eq(files[1])
      end
    end

    context "when no files exist" do
      before do
        allow(Dir).to receive(:glob).and_return([])
      end

      it "returns nil" do
        expect(described_class.find_latest_query_json).to be_nil
      end
    end
  end

  describe ".find_latest_query_json!" do
    context "when no files exist" do
      before do
        allow(described_class).to receive(:find_latest_query_json).and_return(nil)
      end

      it "raises FileNotFoundError" do
        expect { described_class.find_latest_query_json! }
          .to raise_error(PageMigration::FileNotFoundError, /No query.json files found/)
      end
    end
  end

  describe ".find_simple_json_content" do
    context "when exact path exists" do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      it "returns the exact path" do
        result = described_class.find_simple_json_content("Pg4eV6k", "company", "fr")
        expect(result).to eq("tmp/Pg4eV6k_company/contenu_fr.json")
      end
    end

    context "when exact path does not exist but glob finds file" do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(Dir).to receive(:glob).and_return(["tmp/Pg4eV6k_other/contenu_fr.json"])
      end

      it "returns the globbed path" do
        result = described_class.find_simple_json_content("Pg4eV6k", "company", "fr")
        expect(result).to eq("tmp/Pg4eV6k_other/contenu_fr.json")
      end
    end
  end

  describe ".find_simple_json_content!" do
    context "when no file found" do
      before do
        allow(described_class).to receive(:find_simple_json_content).and_return(nil)
      end

      it "raises FileNotFoundError" do
        expect { described_class.find_simple_json_content!("Pg4eV6k", "company", "fr") }
          .to raise_error(PageMigration::FileNotFoundError, /No content file for Pg4eV6k/)
      end
    end
  end

  describe ".find_legacy_json" do
    context "when file exists" do
      before do
        allow(File).to receive(:exist?).with("tmp/Pg4eV6k_organization.json").and_return(true)
      end

      it "returns the path" do
        expect(described_class.find_legacy_json("Pg4eV6k")).to eq("tmp/Pg4eV6k_organization.json")
      end
    end

    context "when file does not exist" do
      before do
        allow(File).to receive(:exist?).with("tmp/NonExistent_organization.json").and_return(false)
      end

      it "returns nil" do
        expect(described_class.find_legacy_json("NonExistent")).to be_nil
      end
    end
  end
end
