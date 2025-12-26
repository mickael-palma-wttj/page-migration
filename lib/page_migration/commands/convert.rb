# frozen_string_literal: true

require "fileutils"

module PageMigration
  module Commands
    # Converts extracted JSON data to Markdown files
    class Convert
      DEFAULT_OUTPUT_DIR = "tmp/org_markdown"

      def initialize(org_ref = nil, input: nil, output_dir: DEFAULT_OUTPUT_DIR)
        @org_ref = org_ref
        @input = input
        @output_dir = output_dir
      end

      def call
        input_file = determine_input
        FileUtils.mkdir_p(@output_dir)
        organizations = Support::JsonLoader.load(input_file)

        organizations.each { |org| process_org(org) }
        puts "\n✅ Generated #{organizations.length} files in #{@output_dir}"
      end

      private

      def determine_input
        return @input if @input
        return Support::FileDiscovery.find_query_json!(@org_ref) if @org_ref

        Support::FileDiscovery.find_latest_query_json || 'tmp/query_result/query.json'
      end

      def process_org(org)
        filename = generate_filename(org)
        filepath = File.join(@output_dir, filename)
        content = MarkdownGenerator.new(org).generate
        File.write(filepath, content)
        puts "  ✓ Written: #{filename} (#{(org["pages"] || []).length} pages)"
      end

      def generate_filename(org)
        slug = Utils.sanitize_filename(org["name"])
        "#{org["reference"].strip}_#{slug}.md"
      end
    end
  end
end
