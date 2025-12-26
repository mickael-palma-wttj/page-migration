# frozen_string_literal: true

require "fileutils"

module PageMigration
  module Generators
    # Generates a hierarchical directory structure with one Markdown file per page
    class TreeExportGenerator
      include Renderers::ContentRenderer

      def initialize(org_data, tree_data, language:, output_dir:, custom_only: false)
        @org = org_data
        @tree = tree_data
        @language = language
        @output_dir = output_dir
        @custom_only = custom_only
        @pages_by_id = build_pages_index(@org)
        @tree_pages = build_tree_index(@tree)
      end

      def generate
        FileUtils.rm_rf(@output_dir)
        FileUtils.mkdir_p(@output_dir)

        root_pages = @tree["page_tree"].select { |p| p["is_root"] }

        root_pages.each do |page|
          export_node(page, @output_dir)
        end
      end

      private

      def export_node(tree_page, current_path)
        is_custom = Renderers::PageClassifier.custom?(tree_page["slug"])
        should_render = !@custom_only || is_custom

        node_dir = determine_node_dir(tree_page, current_path)

        if should_render
          page_data = @pages_by_id[tree_page["id"]]
          if page_data
            FileUtils.mkdir_p(node_dir)
            content = render_page_content(tree_page, page_data)
            File.write(File.join(node_dir, "index.md"), content)
          end
        end

        find_children(@tree, tree_page["id"]).each do |child|
          export_node(child, node_dir)
        end
      end

      def determine_node_dir(tree_page, current_path)
        if tree_page["is_root"] && tree_page["slug"] == "/"
          current_path
        else
          node_name = tree_page["slug"].split("/").last || tree_page["id"].to_s
          File.join(current_path, Utils.sanitize_filename(node_name))
        end
      end

      def render_page_content(tree_page, page_data)
        buffer = []
        status_icon = (tree_page["status"] == "published") ? "✅" : "❌"
        title = tree_page["name"] || "Untitled"

        buffer << "# #{status_icon} #{title}\n\n"
        buffer << "**Slug:** `#{tree_page["slug"]}`\n"
        buffer << "**Reference:** `#{tree_page["reference"] || "none"}`\n"
        buffer << "**Status:** #{tree_page["status"]}\n"
        buffer << "**Published:** #{tree_page["published_at"] || "never"}\n\n"

        buffer << "---\n\n"

        render_blocks(page_data["content_blocks"] || [], buffer)

        buffer.join
      end

      def render_blocks(blocks, buffer)
        blocks.each do |block|
          buffer << "## Block: #{block["kind"]} (ID: #{block["id"]})\n\n"
          render_items(block["content_items"] || [], buffer)
        end
      end

      def render_items(items, buffer)
        items.each do |item|
          if item["record"]
            record_md = Renderers::RecordRenderer.new(item["record"], item["record_type"]).render
            buffer << record_md if record_md
          end

          properties = item["properties"]
          next if properties.nil? || properties.empty?

          properties.each do |key, value|
            rendered = render_property(key, value, @language)
            buffer << rendered if rendered
          end
        end
      end
    end
  end
end
