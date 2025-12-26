# frozen_string_literal: true

RSpec.describe PageMigration::Generators::TextContentGenerator do
  let(:org_data) do
    {
      "name" => "Test Company",
      "reference" => "TestRef",
      "pages" => [
        {
          "name" => "About",
          "slug" => "/about",
          "content_blocks" => [
            {
              "content_items" => [
                {
                  "properties" => {
                    "title" => {"fr" => "Titre", "en" => "Title"},
                    "body" => {"fr" => "Contenu", "en" => "Content"}
                  },
                  "record" => nil,
                  "record_type" => nil
                }
              ]
            }
          ]
        }
      ]
    }
  end

  describe "#generate" do
    context "with French language (default)" do
      let(:generator) { described_class.new(org_data) }

      it "generates text header" do
        result = generator.generate
        expect(result).to include("Test Company")
        expect(result).to include("TestRef")
      end

      it "extracts French content" do
        result = generator.generate
        expect(result).to include("Titre")
        expect(result).to include("Contenu")
      end

      it "outputs page markers" do
        result = generator.generate
        expect(result).to include("PAGE 1/1")
      end
    end

    context "with English language" do
      let(:generator) { described_class.new(org_data, language: "en") }

      it "extracts English content" do
        result = generator.generate
        expect(result).to include("Title")
        expect(result).to include("Content")
      end

      it "falls back to French if English not available" do
        org_data["pages"].first["content_blocks"].first["content_items"].first["properties"]["subtitle"] = {"fr" => "Sous-titre"}
        result = generator.generate
        expect(result).to include("Sous-titre")
      end
    end

    context "with record data" do
      let(:org_with_records) do
        org_data.tap do |o|
          o["pages"].first["content_blocks"].first["content_items"] << {
            "properties" => {},
            "record" => {"name" => "Paris Office", "address" => "123 Street", "city" => "Paris", "country_code" => "FR"},
            "record_type" => "Office"
          }
        end
      end

      let(:generator) { described_class.new(org_with_records) }

      it "renders office record" do
        result = generator.generate
        expect(result).to include("Paris Office")
        expect(result).to include("123 Street, Paris, FR")
      end
    end

    context "deduplication" do
      let(:org_with_duplicates) do
        org_data.tap do |o|
          o["pages"].first["content_blocks"].first["content_items"] << {
            "properties" => {"title" => {"fr" => "Titre"}},
            "record" => nil,
            "record_type" => nil
          }
        end
      end

      let(:generator) { described_class.new(org_with_duplicates) }

      it "deduplicates identical content" do
        result = generator.generate
        expect(result.scan("Titre").length).to eq(1)
      end
    end
  end
end
