# frozen_string_literal: true

require 'fileutils'
require 'json'

module PageMigration
  module Commands
    # Command to export complete organization content as Markdown per language
    class Export
      DEFAULT_OUTPUT_DIR = 'tmp/export'
      LANGUAGES = %w[fr en].freeze

      def initialize(org_ref, output_dir: DEFAULT_OUTPUT_DIR, languages: LANGUAGES, custom_only: false, tree: false)
        @org_ref = org_ref
        @output_dir = output_dir
        @languages = languages
        @custom_only = custom_only
        @tree = tree
      end

      def call
        org_data, tree_data = fetch_data
        if @tree
          generate_tree_exports(org_data, tree_data)
        else
          generate_exports(org_data, tree_data)
        end
      end

      private

      def fetch_data
        Database.with_connection do |conn|
          org_json = OrganizationQuery.new(@org_ref).call(conn)
          tree_json = PageTreeQuery.new(@org_ref).call(conn)

          org_data = JSON.parse(org_json)['organizations'].first
          tree_data = JSON.parse(tree_json)

          [org_data, tree_data]
        end
      rescue PG::Error => e
        raise PageMigration::Error, "Database error: #{e.message}"
      end

      def generate_exports(org_data, tree_data)
        FileUtils.mkdir_p(@output_dir)
        org_name = Utils.sanitize_filename(org_data['name'])

        @languages.each do |lang|
          generate_language_export(org_data, tree_data, org_name, lang)
        end

        print_summary(org_data)
      end

      def generate_tree_exports(org_data, tree_data)
        org_name = Utils.sanitize_filename(org_data['name'])
        company_dir = File.join(@output_dir, "#{@org_ref}_#{org_name}")

        @languages.each do |lang|
          lang_dir = File.join(company_dir, lang)
          generator = TreeExportGenerator.new(org_data, tree_data, language: lang, output_dir: lang_dir, custom_only: @custom_only)
          generator.generate
          puts "  ✅ Generated tree export: #{lang_dir}"
        end

        print_summary(org_data)
      end

      def generate_language_export(org_data, tree_data, org_name, lang)
        generator = FullExportGenerator.new(org_data, tree_data, language: lang, custom_only: @custom_only)
        content = generator.generate

        suffix = @custom_only ? '_custom' : ''
        filename = "#{@org_ref}_#{org_name}_#{lang}#{suffix}.md"
        filepath = File.join(@output_dir, filename)
        File.write(filepath, content)

        puts "  ✅ Generated: #{filepath}"
      end

      def print_summary(org_data)
        puts "\n📁 Export completed for #{org_data['name']}"
        puts "   Languages: #{@languages.join(', ')}"
        puts "   Mode: #{@custom_only ? 'Custom pages only' : 'All pages'}"
        puts "   Output: #{@output_dir}/"
      end
    end
  end
end
