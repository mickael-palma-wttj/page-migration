# frozen_string_literal: true

require 'json'

module PageMigration
  module Generators
    # Generates a complete Markdown export with tree view and all page content by language
    class FullExportGenerator
      include ContentRenderer

      SUPPORTED_LANGUAGES = %w[fr en cs sk].freeze

      def initialize(org_data, tree_data, language:, custom_only: false)
        @org = org_data
        @tree = tree_data
        @language = language
        @custom_only = custom_only
        @buffer = []
        @pages_by_id = build_pages_index(@org)
        @tree_pages = build_tree_index(@tree)
      end

      def generate
        render_header
        render_tree_section
        render_pages_section
        @buffer.join
      end

      private

      def render_header
        title_suffix = @custom_only ? ' (Custom Pages Only)' : ''
        @buffer << "# #{@org['name']} - Content Export (#{@language.upcase})#{title_suffix}\n\n"
        @buffer << "**Organization:** `#{@org['reference']}`\n"
        @buffer << "**Website:** #{@org['website']}\n"
        @buffer << "**Export Date:** #{@tree['export_date']}\n"
        @buffer << "**Language:** #{@language.upcase}\n"
        @buffer << "**Filter:** #{@custom_only ? 'Custom pages only' : 'All pages'}\n\n"
        @buffer << "---\n\n"
      end

      def render_tree_section
        @buffer << "## 📋 Page Tree\n\n"
        @buffer << "```\n"
        render_tree_nodes
        @buffer << "```\n\n"
        render_statistics
        @buffer << "---\n\n"
      end

      def render_tree_nodes
        if @custom_only
          render_flat_tree
        else
          render_hierarchical_tree
        end
      end

      def render_flat_tree
        pages = filtered_tree.sort_by { |p| p['slug'] }
        pages.each_with_index do |page, idx|
          is_last = idx == pages.length - 1
          connector = is_last ? '└── ' : '├── '
          status = page['status'] == 'published' ? '✅' : '❌'
          @buffer << "#{connector}#{status} #{page['slug']}\n"
        end
      end

      def render_hierarchical_tree
        root_pages = @tree['page_tree'].select { |p| p['is_root'] }
        root_pages.each_with_index do |page, idx|
          is_last = idx == root_pages.length - 1
          render_tree_node(page, '', is_last)
        end
      end

      def render_tree_node(page, prefix, is_last)
        is_custom = PageClassifier.custom?(page['slug'])
        should_render = !@custom_only || is_custom

        if should_render
          connector = is_last ? '└── ' : '├── '
          status = page['status'] == 'published' ? '✅' : '❌'
          ref_tag = page['reference'] ? " [#{page['reference']}]" : ''
          @buffer << "#{prefix}#{connector}#{status} #{page['slug']}#{ref_tag}\n"
        end

        children = tree_children(page['id'])
        children.each_with_index do |child, idx|
          child_prefix = prefix + (is_last ? '    ' : '│   ')
          render_tree_node(child, child_prefix, idx == children.length - 1)
        end
      end

      def tree_children(parent_id)
        find_children(@tree, parent_id)
      end

      def filtered_tree
        @filtered_tree ||= if @custom_only
                             (@tree['page_tree'] || []).select { |p| PageClassifier.custom?(p['slug']) }
                           else
                             @tree['page_tree'] || []
                           end
      end

      def render_statistics
        stats = @tree['statistics'] || {}
        total = filtered_tree.size
        roots = filtered_tree.count { |p| p['is_root'] }
        depth = filtered_tree.map { |p| p['depth'] || 0 }.max || 0

        @buffer << "**Statistics:**\n"
        total_text = @custom_only ? "#{total} (#{stats['total_pages']} total)" : total.to_s
        @buffer << "- Total Pages: #{total_text}\n"
        @buffer << "- Root Pages: #{roots}\n"
        @buffer << "- Max Depth: #{depth}\n\n"
      end

      def render_pages_section
        @buffer << "## 📄 Page Contents\n\n"
        if @custom_only
          render_custom_pages
        else
          render_hierarchical_pages
        end
      end

      def render_custom_pages
        pages = filtered_tree.sort_by { |p| p['slug'] }
        pages.each { |tree_page| render_page_standalone(tree_page, 3) }
      end

      def render_hierarchical_pages
        root_pages = @tree['page_tree'].select { |p| p['is_root'] }
        root_pages.each { |tree_page| render_page_with_children(tree_page, 2) }
      end

      def render_page_standalone(tree_page, heading_level)
        page = @pages_by_id[tree_page['id']]
        render_page(tree_page, page, heading_level) if page
      end

      def render_page_with_children(tree_page, heading_level)
        is_custom = PageClassifier.custom?(tree_page['slug'])
        should_render = !@custom_only || is_custom

        if should_render
          page = @pages_by_id[tree_page['id']]
          render_page(tree_page, page, heading_level) if page
        end

        children = tree_children(tree_page['id'])
        children.each { |child| render_page_with_children(child, heading_level + 1) }
      end

      def render_page(tree_page, page, heading_level)
        heading = '#' * [heading_level, 6].min
        status_icon = tree_page['status'] == 'published' ? '✅' : '❌'
        title = tree_page['name'] || 'Untitled'

        @buffer << "#{heading} #{status_icon} #{tree_page['slug']} - #{title}\n\n"
        render_page_meta(tree_page, page)
        render_blocks(page['content_blocks'] || [])
        @buffer << "---\n\n"
      end

      def render_page_meta(tree_page, page)
        @buffer << "| Property | Value |\n"
        @buffer << "|----------|-------|\n"
        @buffer << "| **ID** | `#{page['id']}` |\n"
        @buffer << "| **Reference** | `#{tree_page['reference'] || 'none'}` |\n"
        @buffer << "| **Status** | #{tree_page['status']} |\n"
        @buffer << "| **Published** | #{tree_page['published_at'] || 'never'} |\n\n"
      end

      def render_blocks(blocks)
        return if blocks.nil? || blocks.empty?

        blocks.each { |block| render_block(block) }
      end

      def render_block(block)
        items = block['content_items'] || []
        rendered_items = items.map { |item| render_item_to_string(item) }.compact.reject(&:empty?)
        return if rendered_items.empty?

        @buffer << "**Block: #{block['kind']}** (ID: #{block['id']})\n\n"
        @buffer << rendered_items.join("\n")
        @buffer << "\n\n"
      end

      def render_item_to_string(item)
        item_buffer = []

        if item['record']
          record_md = RecordRenderer.new(item['record'], item['record_type']).render
          item_buffer << record_md if record_md
        end

        properties = item['properties']
        if properties && !properties.empty?
          properties.each do |key, value|
            rendered = render_property(key, value, @language)
            item_buffer << rendered if rendered
          end
        end

        item_buffer.empty? ? nil : item_buffer.join
      end
    end
  end
end
