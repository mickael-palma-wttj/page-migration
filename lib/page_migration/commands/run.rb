# frozen_string_literal: true

module PageMigration
  module Commands
    # Runs both extract and convert in sequence
    class Run
      def initialize(org_ref, json_output: nil, md_output_dir: nil)
        @org_ref = org_ref
        @json_output = json_output
        @md_output_dir = md_output_dir
      end

      def call
        puts "🚀 Running full pipeline for organization: #{@org_ref}\n\n"

        puts "--- Step 1: Extract from database ---"
        json_path = Extract.new(@org_ref, output: @json_output).call

        puts "\n--- Step 2: Convert to Markdown ---"
        Convert.new(input: json_path, output_dir: @md_output_dir).call

        puts "\n🎉 Pipeline complete!"
      end
    end
  end
end
