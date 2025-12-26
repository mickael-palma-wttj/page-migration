# frozen_string_literal: true

require "json"

module PageMigration
  # Generates Markdown content from organization data
  class MarkdownGenerator
    def initialize(org)
      @org = org
      @buffer = []
    end

    def generate
      render_header
      render_pages
      @buffer.join
    end

    private

    def render_header
      @buffer << "# #{@org["name"]}\n\n"
      @buffer << "**Organization Reference:** `#{@org["reference"].strip}`\n"
      @buffer << "**Website:** #{@org["website"]}\n"
      @buffer << "**Created:** #{@org["created_at"]}\n"
      @buffer << "**Updated:** #{@org["updated_at"]}\n\n"
      @buffer << "---\n\n"
    end

    def render_pages
      (@org["pages"] || []).each_with_index { |page, idx| render_page(page, idx + 1) }
    end

    def render_page(page, num)
      render_page_header(page, num)
      render_blocks(page["content_blocks"] || [])
    end

    def render_page_header(page, num)
      @buffer << "## Page #{num}: #{page["name"] || "Untitled"}\n\n"
      @buffer << "**ID:** `#{page["id"]}`\n"
      @buffer << "**Slug:** `#{page["slug"] || "/untitled"}`\n"
      @buffer << "**Reference:** #{format_ref(page["reference"])}\n"
      @buffer << "**Status:** `#{page["status"] || "draft"}`\n"
      @buffer << "**Position:** #{page["position"] || 0}\n"
      @buffer << "**Created:** #{page["created_at"]}\n\n"
    end

    def render_blocks(blocks)
      blocks.each_with_index { |block, idx| render_block(block, idx + 1) }
    end

    def render_block(block, num)
      @buffer << "### Block #{num}: #{block["kind"]}\n\n"
      @buffer << "**ID:** `#{block["id"]}`\n"
      @buffer << "**Position:** #{block["position"] || 0}\n"
      @buffer << "**Created:** #{block["created_at"]}\n\n"
      render_items(block["content_items"] || [])
    end

    def render_items(items)
      items.each_with_index { |item, idx| render_item(item, idx + 1) }
    end

    def render_item(item, num)
      @buffer << "#### Item #{num}: #{item["kind"] || "N/A"}\n\n"
      @buffer << "- **ID:** `#{item["id"]}`\n"
      @buffer << "- **Kind:** `#{item["kind"] || "N/A"}`\n"
      @buffer << "- **Record Type:** `#{item["record_type"] || "N/A"}`\n"
      @buffer << "- **Position:** #{item["position"] || 0}\n"

      record_md = Renderers::RecordRenderer.new(item["record"], item["record_type"]).render
      @buffer << record_md if record_md
      render_properties(item["properties"])
    end

    def render_properties(properties)
      return if properties.nil? || properties.empty?

      @buffer << "- **Properties:**\n\n"
      @buffer << "```json\n#{JSON.generate(properties)}\n```\n\n"
    end

    def format_ref(ref)
      ref.nil? ? "null" : "`#{ref}`"
    end
  end
end
