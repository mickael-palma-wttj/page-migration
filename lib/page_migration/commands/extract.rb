# frozen_string_literal: true

require "json"
require "fileutils"

module PageMigration
  module Commands
    # Extracts organization data from database to JSON or text format
    class Extract
      FORMATS = %w[json text].freeze

      def initialize(org_ref, output: nil, format: "json", language: "fr")
        @org_ref = org_ref
        @output = output
        @format = format
        @language = language
      end

      def call
        conn = Database.connect
        json_data = OrganizationQuery.new(@org_ref).call(conn)
        org_data = JSON.parse(json_data)["organizations"].first

        @output ||= build_default_output(org_data)
        FileUtils.mkdir_p(File.dirname(@output))

        case @format
        when "json"
          write_json(json_data)
        when "text"
          write_text(org_data)
        end

        @output
      rescue PG::Error => e
        abort "❌ Database error: #{e.message}"
      rescue PageMigration::Error => e
        abort "❌ Error: #{e.message}"
      ensure
        conn&.close
      end

      private

      def build_default_output(org_data)
        slug = sanitize(org_data["name"])
        case @format
        when "json"
          "tmp/query_result/#{@org_ref}_#{slug}/query.json"
        when "text"
          "tmp/query_result/#{@org_ref}_#{slug}/contenu_#{@language}.txt"
        end
      end

      def sanitize(name)
        Utils.sanitize_filename(name)
      end

      def write_json(data)
        formatted = JSON.pretty_generate(JSON.parse(data))
        File.write(@output, formatted)
        puts "✅ Exported to: #{@output}"
      end

      def write_text(org_data)
        generator = TextContentGenerator.new(org_data, language: @language)
        content = generator.generate
        File.write(@output, content)
        puts "✅ Text content extracted to: #{@output}"
      end
    end
  end
end
