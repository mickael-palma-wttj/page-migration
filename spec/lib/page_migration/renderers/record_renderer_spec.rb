# frozen_string_literal: true

RSpec.describe PageMigration::Renderers::RecordRenderer do
  describe "#render" do
    context "with nil record" do
      it "returns nil" do
        renderer = described_class.new(nil, "Cms::Image")
        expect(renderer.render).to be_nil
      end
    end

    context "with unsupported record type" do
      it "returns nil" do
        renderer = described_class.new({}, "Unknown::Type")
        expect(renderer.render).to be_nil
      end
    end

    context "with Cms::Image" do
      let(:record) { {"file" => "image.png", "name" => "Logo", "description" => "Company logo"} }

      it "renders image record" do
        renderer = described_class.new(record, "Cms::Image")
        result = renderer.render
        expect(result).to include("🖼️ **Image:** `image.png`")
        expect(result).to include("**Name:** Logo")
        expect(result).to include("**Description:** Company logo")
      end

      it "skips placeholder images" do
        placeholder = {"file" => "b3c3cb40-63aa-4477-b6e3-b8b03ebccb75.png"}
        renderer = described_class.new(placeholder, "Cms::Image")
        expect(renderer.render).to be_nil
      end

      it "omits empty name and description" do
        minimal = {"file" => "image.png", "name" => nil, "description" => ""}
        renderer = described_class.new(minimal, "Cms::Image")
        result = renderer.render
        expect(result).not_to include("**Name:**")
        expect(result).not_to include("**Description:**")
      end
    end

    context "with Cms::Video" do
      let(:record) { {"source" => "youtube", "external_reference" => "abc123", "name" => "Demo", "description" => "Product demo", "image" => "thumb.jpg"} }

      it "renders video record" do
        renderer = described_class.new(record, "Cms::Video")
        result = renderer.render
        expect(result).to include("🎬 **Video:** youtube - `abc123`")
        expect(result).to include("**Name:** Demo")
        expect(result).to include("**Description:** Product demo")
        expect(result).to include("**Thumbnail:** `thumb.jpg`")
      end
    end

    context "with Organization" do
      let(:record) { {"name" => "Acme Corp", "reference" => "AcmeRef"} }

      it "renders organization record" do
        renderer = described_class.new(record, "Organization")
        result = renderer.render
        expect(result).to include("🏢 **Organization:** Acme Corp (`AcmeRef`)")
      end
    end

    context "with Office" do
      let(:record) { {"name" => "Paris HQ", "address" => "123 Avenue", "city" => "Paris", "country_code" => "FR"} }

      it "renders office record" do
        renderer = described_class.new(record, "Office")
        result = renderer.render
        expect(result).to include("📍 **Office:** Paris HQ")
        expect(result).to include("**Address:** 123 Avenue, Paris, FR")
      end

      it "handles missing address parts" do
        minimal = {"name" => "Remote Office", "address" => nil, "city" => nil, "country_code" => nil}
        renderer = described_class.new(minimal, "Office")
        result = renderer.render
        expect(result).to include("📍 **Office:** Remote Office")
        expect(result).not_to include("**Address:**")
      end
    end

    context "with WebsiteOrganization" do
      let(:record) { {"organization_name" => "Partner Corp", "organization_reference" => "PartnerRef"} }

      it "renders website organization record" do
        renderer = described_class.new(record, "WebsiteOrganization")
        result = renderer.render
        expect(result).to include("🌐 **Website Org:** Partner Corp (`PartnerRef`)")
      end
    end
  end

  describe "RENDERERS" do
    it "maps record types to renderer methods" do
      expect(described_class::RENDERERS.keys).to contain_exactly(
        "Cms::Image", "Cms::Video", "Organization", "Office", "WebsiteOrganization"
      )
    end
  end
end
