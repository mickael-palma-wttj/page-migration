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
          slug = Utils.sanitize_filename(org_data["name"])
          @output = "tmp/query_result/#{@org_ref}_#{slug}/tree.json"
        end

        write_output(data)
        ShowTree.new(input: @output).call
        @output
      end

      private

      def fetch_data
        Database.with_connection do |conn|
          PageTreeQuery.new(@org_ref).call(conn)
        end
      rescue PG::Error => e
        raise PageMigration::Error, "Database error: #{e.message}"
      end

      def write_output(data)
        FileUtils.mkdir_p(File.dirname(@output))
        File.write(@output, JSON.pretty_generate(JSON.parse(data)))
      end
    end
  end
end
