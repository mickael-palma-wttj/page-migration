# frozen_string_literal: true

RSpec.describe PageMigration::Support::JsonLoader do
  describe ".load" do
    context "when file does not exist" do
      it "raises an error" do
        expect { described_class.load("/nonexistent/path.json") }
          .to raise_error(PageMigration::Error, /File not found/)
      end
    end

    context "when file exists" do
      let(:temp_file) { Tempfile.new(["test", ".json"]) }

      after { temp_file.unlink }

      it "parses simple JSON with organizations" do
        temp_file.write('{"organizations": [{"name": "Org1"}]}')
        temp_file.rewind

        result = described_class.load(temp_file.path)
        expect(result).to eq([{"name" => "Org1"}])
      end

      it "handles nested data key" do
        temp_file.write('{"data": "{\"organizations\": [{\"name\": \"Org1\"}]}"}')
        temp_file.rewind

        result = described_class.load(temp_file.path)
        expect(result).to eq([{"name" => "Org1"}])
      end

      it "handles string organizations value" do
        temp_file.write('{"organizations": "[{\"name\": \"Org1\"}]"}')
        temp_file.rewind

        result = described_class.load(temp_file.path)
        expect(result).to eq([{"name" => "Org1"}])
      end
    end
  end

  describe ".parse_data" do
    it "extracts data from nested structure" do
      content = '{"data": "{\"organizations\": [{\"id\": 1}]}"}'
      result = described_class.parse_data(content)
      expect(result).to eq([{"id" => 1}])
    end

    it "handles direct organizations key" do
      content = '{"organizations": [{"id": 1}]}'
      result = described_class.parse_data(content)
      expect(result).to eq([{"id" => 1}])
    end
  end

  describe ".extract_organizations" do
    it "returns array when organizations is already an array" do
      data = {"organizations" => [{"id" => 1}]}
      result = described_class.extract_organizations(data)
      expect(result).to eq([{"id" => 1}])
    end

    it "parses JSON when organizations is a string" do
      data = {"organizations" => '[{"id": 1}]'}
      result = described_class.extract_organizations(data)
      expect(result).to eq([{"id" => 1}])
    end
  end
end
