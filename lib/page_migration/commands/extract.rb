# frozen_string_literal: true

require "json"
require "fileutils"

module PageMigration
  module Commands
    # Extracts organization data from database to JSON format
    # - json: raw database export with full structure
    # - simple-json: simplified content export with flat page array
    class Extract
      FORMATS = %w[json simple-json].freeze

      def initialize(org_ref, output: nil, format: "json", language: "fr")
        @org_ref = org_ref
        @output = output
        @format = format
        @language = language
      end

      def call
        Database.with_connection do |conn|
          json_data = Queries::OrganizationQuery.new(@org_ref).call(conn)
          org_data = JSON.parse(json_data)["organizations"].first

          @output ||= build_default_output(org_data)
          FileUtils.mkdir_p(File.dirname(@output))

          case @format
          when "json"
            write_json(json_data)
          when "simple-json"
            tree_json = Queries::PageTreeQuery.new(@org_ref).call(conn)
            tree_data = JSON.parse(tree_json)
            write_simple_json(org_data, tree_data)
          end
        end

        @output
      rescue PG::Error => e
        abort "❌ Database error: #{e.message}"
      rescue PageMigration::Error => e
        abort "❌ Error: #{e.message}"
      end

      private

      def build_default_output(org_data)
        base_dir = Config.output_dir(@org_ref, org_data["name"])
        case @format
        when "json"
          File.join(base_dir, Config::QUERY_JSON)
        when "simple-json"
          File.join(base_dir, "contenu_#{@language}.json")
        end
      end

      def write_json(data)
        formatted = JSON.pretty_generate(JSON.parse(data))
        File.write(@output, formatted)
        puts "✅ Exported to: #{@output}"
      end

      def write_simple_json(org_data, tree_data)
        generator = Generators::SimpleJsonGenerator.new(org_data, tree_data: tree_data, language: @language)
        File.write(@output, generator.to_json)
        puts "✅ Content extracted to: #{@output}"
      end
    end
  end
end
