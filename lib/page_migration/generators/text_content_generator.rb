# frozen_string_literal: true

require 'json'
require 'set'

module PageMigration
  module Generators
    # Generates a plain text export of all content for an organization
    class TextContentGenerator
      def initialize(org_data, language: 'fr')
        @org = org_data
        @language = language
        @buffer = []
        @seen_content = Set.new
      end

      def generate
        render_header
        render_pages
        @buffer.join("\n")
      end

      private

      def render_header
        @buffer << "=" * 80
        @buffer << "CONTENU #{@language.upcase == 'FR' ? 'FRANÇAIS' : 'ENGLISH'} - #{@org['name']} (#{@org['reference']})"
        @buffer << "=" * 80
        @buffer << "\n"
      end

      def render_pages
        pages = @org['pages'] || []
        pages.each_with_index do |page, idx|
          render_page(page, idx + 1, pages.length)
        end
      end

      def render_page(page, index, total)
        @buffer << "\n"
        @buffer << "█" * 80
        @buffer << "PAGE #{index}/#{total} : #{page['name'] || page['slug'].upcase}"
        @buffer << "█" * 80
        @buffer << "\n"

        blocks = page['content_blocks'] || []
        blocks.each do |block|
          render_block(block)
        end

        @buffer << "-" * 80
        @buffer << "\n"
      end

      def render_block(block)
        items = block['content_items'] || []
        items.each do |item|
          render_item(item)
        end
      end

      def render_item(item)
        props = item['properties'] || {}
        extract_text_from_properties(props)

        render_record(item['record'], item['record_type']) if item['record']
      end

      def extract_text_from_properties(props)
        %w[title subtitle body content description name value].each do |key|
          val = props[key]
          if val.is_a?(Hash)
            text = val[@language] || val['fr'] || val['en']
            append_text(text) if text
          elsif val.is_a?(String) && !val.empty?
            append_text(val)
          end
        end
      end

      def render_record(record, type)
        case type
        when 'Office'
          append_text(record['name'])
          address = [record['address'], record['city'], record['country_code']].compact.join(', ')
          append_text(address) unless address.empty?
        when 'Organization'
          append_text(record['name'])
        when 'Cms::Image', 'Cms::Video'
          append_text(record['name']) if record['name']
          append_text(record['description']) if record['description']
        end
      end

      def append_text(text)
        return if text.nil? || text.to_s.strip.empty?

        clean_text = text.to_s.gsub("\r\n", "\n").strip
        fingerprint = normalize_for_dedup(clean_text)

        return if @seen_content.include?(fingerprint)

        @seen_content.add(fingerprint)
        @buffer << clean_text
        @buffer << ""
      end

      def normalize_for_dedup(text)
        text.downcase.gsub(/\s+/, ' ').strip
      end
    end
  end
end
