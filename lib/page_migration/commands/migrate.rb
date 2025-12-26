# frozen_string_literal: true

require 'json'
require 'fileutils'

module PageMigration
  module Commands
    # Command to generate assets using Dust API based on prompts
    class Migrate
      EXPORT_DIR = 'tmp/export'

      def initialize(org_ref, language: 'fr', debug: false)
        @org_ref = org_ref
        @language = language
        @debug = debug

        @client = PageMigration::Dust::Client.new(
          ENV.fetch('DUST_WORKSPACE_ID'),
          ENV.fetch('DUST_API_KEY'),
          debug: @debug
        )

        dust_runner = PageMigration::Dust::Runner.new(@client, ENV.fetch('DUST_AGENT_ID'), debug: @debug)
        @processor = PageMigration::Services::PromptProcessor.new(@client, {}, dust_runner, language: @language, debug: @debug)
        @prompt_runner = PageMigration::Services::PromptRunner.new(@processor, debug: @debug)
      end

      def call
        org_data = load_org_data
        txt_file = ensure_text_exported(org_data)

        puts "📖 Using content from: #{txt_file}"
        content_summary = File.read(txt_file)

        debug_log "Content size: #{content_summary.bytesize} bytes"
        debug_log "Language: #{@language}"

        output_root = build_output_root(org_data)
        debug_log "Output directory: #{output_root}"

        run_migration_workflow(content_summary, output_root)
      end

      private

      def load_org_data
        input_file = find_input_file
        data = Support::JsonLoader.load(input_file).first
        raise PageMigration::Error, 'No organization data found' unless data

        data
      end

      def ensure_text_exported(org_data)
        txt_file = find_exported_txt(org_data)
        return txt_file if txt_file && File.exist?(txt_file)

        puts '⚠️ Exported Text not found. Running extract --format text first...'
        Extract.new(@org_ref, format: 'text', language: @language).call
        find_exported_txt(org_data) || raise(PageMigration::Error, 'Text extraction failed')
      end

      def find_exported_txt(org_data)
        org_name = Utils.sanitize_filename(org_data['name'])
        Support::FileDiscovery.find_text_content(@org_ref, org_name, @language)
      end

      def ensure_markdown_exported(org_data)
        md_file = find_exported_md(org_data)
        return md_file if md_file && File.exist?(md_file)

        puts '⚠️ Exported Markdown not found. Running export first...'
        Export.new(@org_ref, languages: [@language]).call
        find_exported_md(org_data) || raise(PageMigration::Error, 'Export failed')
      end

      def build_output_root(org_data)
        org_name = Utils.sanitize_filename(org_data['name'])
        root = "tmp/generated_assets/#{@org_ref}_#{org_name}"
        FileUtils.mkdir_p(root)
        root
      end

      def run_migration_workflow(summary, output_root)
        puts "\n🔍 Running brand analysis..."
        analysis_result = run_analysis(summary, output_root)
        debug_log "Brand analysis complete" if analysis_result

        prompts = Dir.glob('prompts/migration/**/*.prompt.md').sort
        prompts.reject! { |p| p.include?('file_analysis.prompt.md') }

        debug_log "Found #{prompts.length} prompts to process"
        prompts.each { |p| debug_log "  - #{p}" } if @debug

        @prompt_runner.run(prompts, summary, output_root, additional_instructions: analysis_result)

        puts "\n✅ Migration complete! Assets generated in #{output_root}/"
      end

      def run_analysis(summary, output_root)
        path = 'prompts/migration/file_analysis.prompt.md'
        return nil unless File.exist?(path)

        @processor.process(path, summary, output_root)
      end

      def find_exported_md(org_data)
        org_name = Utils.sanitize_filename(org_data['name'])
        path = File.join(EXPORT_DIR, "#{@org_ref}_#{org_name}_#{@language}.md")
        return path if File.exist?(path)

        Dir.glob(File.join(EXPORT_DIR, "#{@org_ref}_*_#{@language}.md")).first
      end

      def debug_log(message)
        puts "[DEBUG] #{message}" if @debug
      end

      def find_input_file
        path = Support::FileDiscovery.find_query_json(@org_ref)
        return path if path

        path = Support::FileDiscovery.find_legacy_json(@org_ref)
        return path if path

        puts "⚠️ Organization data not found for #{@org_ref}. Running extract first..."
        Extract.new(@org_ref).call
      end
    end
  end
end
