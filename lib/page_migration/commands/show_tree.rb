# frozen_string_literal: true

require "json"

module PageMigration
  module Commands
    # Command to display page tree hierarchy in visual format
    class ShowTree
      include Renderers::TreeRenderer

      DEFAULT_INPUT = "query_result/page_tree.json"
      SEPARATOR_LENGTH = 100

      def initialize(input: DEFAULT_INPUT)
        @input = input
      end

      def call
        validate_input_file
        data = load_data
        display_tree(data)
      end

      private

      def validate_input_file
        return if File.exist?(@input)

        raise PageMigration::Error, "File not found: #{@input}"
      end

      def load_data
        JSON.parse(File.read(@input))
      end

      def display_tree(data)
        organization = data["organization"]
        pages = data["page_tree"] || []

        pages_by_ancestry = build_ancestry_index(pages)
        pages_by_id = pages.each_with_object({}) { |p, h| h[p["id"]] = p }

        print_header(organization, data)
        render_tree(nil, pages_by_ancestry, pages_by_id)
        print_statistics(pages)
      end

      def build_ancestry_index(pages)
        pages.each_with_object({}) do |page, index|
          ancestry_key = page["ancestry"]
          index[ancestry_key] ||= []
          index[ancestry_key] << page
        end
      end

      def print_header(organization, data)
        puts "\n#{"=" * SEPARATOR_LENGTH}"
        puts "📋 PAGE TREE VIEW - #{organization["name"]} (#{organization["reference"]})"
        puts "=" * SEPARATOR_LENGTH
        puts "Website: #{organization["website"]} | Export: #{data["export_date"]}"
        puts "-" * SEPARATOR_LENGTH
        puts
        puts "🌳 PAGE HIERARCHY"
        puts
      end

      def render_tree(parent_id, pages_by_ancestry, pages_by_id, prefix = "")
        children = get_children(parent_id, pages_by_ancestry)
        return if children.empty?

        children.each_with_index do |page, index|
          is_last_child = index == children.length - 1
          print_page_line(page, prefix, is_last_child)
          render_tree(page["id"].to_s, pages_by_ancestry, pages_by_id, tree_prefix(prefix, is_last_child))
        end
      end

      def get_children(parent_id, pages_by_ancestry)
        (pages_by_ancestry[parent_id] || []).sort_by { |p| p["position"] }
      end

      def print_page_line(page, prefix, is_last_child)
        ref_str = page["reference"] ? " [#{page["reference"]}]" : ""
        pub_str = page["published_at"] ? " (published)" : ""

        line = "#{prefix}#{tree_connector(is_last_child)}#{status_icon(page["status"])} #{page["slug"].ljust(35)}"
        line += ref_str unless ref_str.empty?
        line += pub_str unless pub_str.empty?

        puts line
      end

      def print_statistics(pages)
        stats = calculate_statistics(pages)
        print_statistics_output(stats)
      end

      def calculate_statistics(pages)
        {
          total: pages.length,
          root: pages.count { |p| p["is_root"] },
          child: pages.count { |p| !p["is_root"] },
          published: pages.count { |p| p["status"] == "published" },
          draft: pages.count { |p| p["status"] == "draft" },
          max_depth: pages.map { |p| p["depth"] }.max || 0
        }
      end

      def print_statistics_output(stats)
        puts
        puts "-" * SEPARATOR_LENGTH
        puts "\n📊 STATISTICS"
        puts "├─ Total Pages: #{stats[:total]}"
        puts "├─ Root Pages: #{stats[:root]}"
        puts "├─ Child Pages: #{stats[:child]}"
        puts "├─ Published: #{stats[:published]} ✅"
        puts "├─ Draft: #{stats[:draft]} ❌"
        puts "└─ Max Depth: #{stats[:max_depth]}"
        puts "\n#{"=" * SEPARATOR_LENGTH}"
      end
    end
  end
end
