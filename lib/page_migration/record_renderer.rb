# frozen_string_literal: true

module PageMigration
  # Renders record data to Markdown based on record type
  class RecordRenderer
    RENDERERS = {
      'Cms::Image' => :render_image,
      'Cms::Video' => :render_video,
      'Organization' => :render_organization,
      'Office' => :render_office,
      'WebsiteOrganization' => :render_website_org
    }.freeze

    def initialize(record, record_type)
      @record = record
      @record_type = record_type
    end

    def render
      return nil unless @record

      renderer = RENDERERS[@record_type]
      return nil unless renderer

      content = send(renderer)
      return nil if content.nil? || content.strip.empty?

      "- **Record:**\n#{content}\n"
    end

    private

    def render_image
      return nil if placeholder_image?

      lines = ["  - 🖼️ **Image:** `#{@record['file']}`"]
      lines << "  - **Name:** #{@record['name']}" unless Utils.empty_value?(@record['name'])
      lines << "  - **Description:** #{@record['description']}" unless Utils.empty_value?(@record['description'])
      "#{lines.join("\n")}\n"
    end

    def placeholder_image?
      @record['file'] == 'b3c3cb40-63aa-4477-b6e3-b8b03ebccb75.png'
    end

    def render_video
      lines = ["  - 🎬 **Video:** #{@record['source']} - `#{@record['external_reference']}`"]
      lines << "  - **Name:** #{@record['name']}" if @record['name']
      lines << "  - **Description:** #{@record['description']}" if @record['description']
      lines << "  - **Thumbnail:** `#{@record['image']}`" if @record['image']
      "#{lines.join("\n")}\n"
    end

    def render_organization
      "  - 🏢 **Organization:** #{@record['name']} (`#{@record['reference']}`)\n"
    end

    def render_office
      address = [@record['address'], @record['city'], @record['country_code']].compact.join(', ')
      lines = ["  - 📍 **Office:** #{@record['name']}"]
      lines << "  - **Address:** #{address}" unless address.empty?
      "#{lines.join("\n")}\n"
    end

    def render_website_org
      "  - 🌐 **Website Org:** #{@record['organization_name']} (`#{@record['organization_reference']}`)\n"
    end
  end
end
