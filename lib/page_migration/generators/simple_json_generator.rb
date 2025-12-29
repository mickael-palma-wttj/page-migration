# frozen_string_literal: true

require "json"
require "time"

module PageMigration
  module Generators
    # Generates a simple JSON export with flat page array and extracted text content
    class SimpleJsonGenerator
      def initialize(org_data, tree_data: nil, language: "fr")
        @org = org_data
        @tree_data = tree_data
        @language = language
        @pages_by_id = build_pages_index
      end

      def generate
        {
          organization: {
            reference: @org["reference"],
            name: @org["name"]
          },
          language: @language,
          exported_at: Time.now.iso8601,
          pages: build_pages_array
        }
      end

      def to_json
        JSON.pretty_generate(generate)
      end

      private

      def build_pages_index
        pages = @org["pages"] || []
        pages.each_with_object({}) { |p, h| h[p["id"]] = p }
      end

      def build_pages_array
        ordered_pages = build_ordered_pages
        ordered_pages.each_with_index.map do |page_info, idx|
          build_page_entry(page_info, idx)
        end
      end

      def build_ordered_pages
        if @tree_data && @tree_data["page_tree"]
          build_hierarchical_order
        else
          (@org["pages"] || []).map { |p| {page: p, depth: 0, slug: p["slug"]} }
        end
      end

      def build_hierarchical_order
        tree_pages = @tree_data["page_tree"] || []
        roots = tree_pages.select { |p| p["is_root"] }
        result = []

        roots.sort_by { |p| [p["position"] || 0, p["slug"] || ""] }.each do |root|
          collect_with_children(root, tree_pages, result)
        end

        result
      end

      def collect_with_children(tree_page, all_tree_pages, result)
        page_data = @pages_by_id[tree_page["id"]]
        if page_data
          result << {
            page: page_data,
            depth: tree_page["depth"] || 0,
            slug: tree_page["slug"]
          }
        end

        children = all_tree_pages.select { |p| p["ancestry"] == tree_page["id"].to_s }
        children.sort_by { |p| [p["position"] || 0, p["slug"] || ""] }.each do |child|
          collect_with_children(child, all_tree_pages, result)
        end
      end

      def build_page_entry(page_info, order)
        page = page_info[:page]
        slug = page_info[:slug] || page["slug"] || "/"

        {
          order: order,
          slug: slug,
          depth: page_info[:depth],
          content: extract_page_content(page)
        }
      end

      def extract_page_content(page)
        seen_content = Set.new
        content = []

        blocks = page["content_blocks"] || []
        blocks.each do |block|
          items = block["content_items"] || []
          items.each do |item|
            extract_item_content(item, content, seen_content)
          end
        end

        content
      end

      def extract_item_content(item, content, seen_content)
        props = item["properties"] || {}

        # Primary content properties
        %w[title subtitle surtitle body content description name value].each do |key|
          add_localized_text(props, key, content, seen_content)
        end

        # Labels and links
        %w[label link_title topic].each do |key|
          add_localized_text(props, key, content, seen_content)
        end

        # Percent values
        if props["percent"]
          val = props["percent"]
          text = val.is_a?(Hash) ? (val[@language] || val["fr"] || val["en"]) : val
          add_text("#{text}%", content, seen_content) if text && !text.to_s.empty?
        end

        # Records
        extract_record_content(item["record"], item["record_type"], content, seen_content) if item["record"]
      end

      def add_localized_text(props, key, content, seen_content)
        val = props[key]
        if val.is_a?(Hash)
          text = val[@language] || val["fr"] || val["en"]
          add_text(text, content, seen_content) if text
        elsif val.is_a?(String) && !val.empty?
          add_text(val, content, seen_content)
        end
      end

      def extract_record_content(record, type, content, seen_content)
        case type
        when "Office"
          office_name = record["name"]
          office_name += " (Headquarters)" if record["is_headquarter"]
          add_text(office_name, content, seen_content)
          address = [record["address"], record["zip_code"], record["city"], record["country_code"]].compact.join(", ")
          add_text(address, content, seen_content) unless address.empty?
        when "Organization"
          add_text(record["name"], content, seen_content)
        when "Cms::Image", "Cms::Video"
          add_text(record["name"], content, seen_content) if record["name"]
          add_text(record["description"], content, seen_content) if record["description"]
        end
      end

      def add_text(text, content, seen_content)
        return if text.nil? || text.to_s.strip.empty?

        clean_text = text.to_s.gsub("\r\n", "\n").strip
        fingerprint = clean_text.downcase.gsub(/\s+/, " ").strip

        return if seen_content.include?(fingerprint)

        seen_content.add(fingerprint)
        content << clean_text
      end
    end
  end
end
