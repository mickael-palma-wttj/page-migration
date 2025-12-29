# frozen_string_literal: true

require "fileutils"

module PageMigration
  module Commands
    # Converts extracted JSON data to Markdown files
    class Convert
      def initialize(org_ref = nil, input: nil, output_dir: nil)
        @org_ref = org_ref
        @input = input
        @output_dir = output_dir
      end

      def call
        input_file = determine_input
        organizations = Support::JsonLoader.load(input_file)

        organizations.each { |org| process_org(org) }
        puts "\n✅ Generated #{organizations.length} markdown files"
      end

      private

      def determine_input
        return @input if @input
        return Support::FileDiscovery.find_query_json!(@org_ref) if @org_ref

        Support::FileDiscovery.find_latest_query_json || "tmp/query.json"
      end

      def process_org(org)
        output_dir = @output_dir || Config.output_dir(org["reference"], org["name"])
        FileUtils.mkdir_p(output_dir)

        filename = "#{org["reference"].strip}_#{Utils.sanitize_filename(org["name"])}.md"
        filepath = File.join(output_dir, filename)
        content = MarkdownGenerator.new(org).generate
        File.write(filepath, content)
        puts "  ✓ Written: #{filepath} (#{(org["pages"] || []).length} pages)"
      end
    end
  end
end
