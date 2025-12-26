# frozen_string_literal: true

require "fileutils"
require "json"

module PageMigration
  module Commands
    # Command to extract page tree hierarchy from database
    class ExtractTree
      def initialize(org_ref, output: nil)
        @org_ref = org_ref
        @output = output
      end

      def call
        data = fetch_data

        if @output.nil?
          org_data = JSON.parse(data)["organization"]
          slug = sanitize_filename(org_data["name"])
          @output = "tmp/query_result/#{@org_ref}_#{slug}/tree.json"
        end

        write_output(data)
        ShowTree.new(input: @output).call
        @output
      end

      private

      def sanitize_filename(name)
        name.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
      end

      def fetch_data
        conn = Database.connect
        PageTreeQuery.new(@org_ref).call(conn)
      rescue PG::Error => e
        raise PageMigration::Error, "Database error: #{e.message}"
      ensure
        conn&.close
      end

      def write_output(data)
        FileUtils.mkdir_p(File.dirname(@output))
        File.write(@output, JSON.pretty_generate(JSON.parse(data)))
      end
    end
  end
end
