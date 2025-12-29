# frozen_string_literal: true

require "json"
require "fileutils"

module PageMigration
  module Commands
    # Command to generate assets using Dust API based on prompts
    class Migrate
      include Loggable

      PROMPTS_DIR = File.expand_path("../prompts/migration", __dir__)
      ANALYSIS_PROMPT = File.expand_path("../prompts/analysis.prompt.md", __dir__)

      def initialize(org_ref, language: "fr", debug: false, analysis: false, dry_run: false)
        @org_ref = org_ref
        @language = language
        @debug = debug
        @analysis_only = analysis
        @dry_run = dry_run

        return if @dry_run

        @client = PageMigration::Dust::Client.new(
          ENV.fetch("DUST_WORKSPACE_ID"),
          ENV.fetch("DUST_API_KEY"),
          debug: @debug
        )

        dust_runner = PageMigration::Dust::Runner.new(@client, ENV.fetch("DUST_AGENT_ID"), debug: @debug)
        @processor = PageMigration::Services::PromptProcessor.new(@client, {}, dust_runner, language: @language, debug: @debug)
        @prompt_runner = PageMigration::Services::PromptRunner.new(@processor, debug: @debug)
      end

      def call
        org_data = load_org_data

        if @dry_run
          run_dry_run(org_data)
          return
        end

        txt_file = ensure_text_exported(org_data)

        puts "📖 Using content from: #{txt_file}"
        content_summary = File.read(txt_file)

        debug_log "Content size: #{content_summary.bytesize} bytes"
        debug_log "Language: #{@language}"

        if @analysis_only
          run_analysis_only(org_data, content_summary)
        else
          output_root = build_output_root(org_data)
          debug_log "Output directory: #{output_root}"
          run_migration_workflow(content_summary, output_root)
        end
      end

      private

      def run_dry_run(org_data)
        puts "🔍 Dry run mode - showing what would be executed\n\n"

        output_dir = Config.output_dir(@org_ref, org_data["name"])
        txt_file = find_exported_txt(org_data)

        puts "📋 Configuration:"
        puts "   Organization: #{org_data["name"]} (#{@org_ref})"
        puts "   Language: #{@language}"
        puts "   Output directory: #{output_dir}"
        puts "   Text content: #{txt_file || "(would be generated)"}"
        puts ""

        if @analysis_only
          puts "📊 Analysis mode:"
          puts "   Would run: #{ANALYSIS_PROMPT}"
          puts "   Output: #{File.join(output_dir, "analysis.md")}"
        else
          prompts = Dir.glob(File.join(PROMPTS_DIR, "**/*.prompt.md")).sort
          prompts.reject! { |p| p.include?("file_analysis.prompt.md") }

          puts "📝 Prompts to process (#{prompts.length}):"
          prompts.each_with_index do |prompt, idx|
            name = File.basename(prompt, ".prompt.md")
            puts "   #{idx + 1}. #{name}"
          end
        end

        puts "\n✅ Dry run complete - no changes made"
      end

      def run_analysis_only(org_data, content_summary)
        puts "\n📊 Running page migration fit analysis..."

        unless File.exist?(ANALYSIS_PROMPT)
          raise PageMigration::Error, "Analysis prompt not found: #{ANALYSIS_PROMPT}"
        end

        output_dir = Config.output_dir(@org_ref, org_data["name"])
        FileUtils.mkdir_p(output_dir)
        output_file = File.join(output_dir, "analysis.md")

        result = @processor.process(ANALYSIS_PROMPT, content_summary, output_dir, save: false)

        if result
          File.write(output_file, strip_markdown_fences(result))
          puts "\n✅ Analysis complete!"
          puts "   Output: #{output_file}"
        else
          raise PageMigration::Error, "Analysis failed - no result returned"
        end
      end

      def load_org_data
        input_file = find_input_file
        data = Support::JsonLoader.load(input_file).first
        raise PageMigration::Error, "No organization data found" unless data

        data
      end

      def ensure_text_exported(org_data)
        txt_file = find_exported_txt(org_data)
        return txt_file if txt_file && File.exist?(txt_file)

        puts "⚠️ Exported Text not found. Running extract --format text first..."
        Extract.new(@org_ref, format: "text", language: @language).call
        find_exported_txt(org_data) || raise(PageMigration::Error, "Text extraction failed")
      end

      def find_exported_txt(org_data)
        org_name = Utils.sanitize_filename(org_data["name"])
        Support::FileDiscovery.find_text_content(@org_ref, org_name, @language)
      end

      def ensure_markdown_exported(org_data)
        md_file = find_exported_md(org_data)
        return md_file if md_file && File.exist?(md_file)

        puts "⚠️ Exported Markdown not found. Running export first..."
        Export.new(@org_ref, languages: [@language]).call
        find_exported_md(org_data) || raise(PageMigration::Error, "Export failed")
      end

      def build_output_root(org_data)
        root = Config.output_dir(@org_ref, org_data["name"])
        FileUtils.mkdir_p(root)
        root
      end

      def run_migration_workflow(summary, output_root)
        puts "\n🔍 Running brand analysis..."
        analysis_result = run_analysis(summary, output_root)
        debug_log "Brand analysis complete" if analysis_result

        prompts = Dir.glob(File.join(PROMPTS_DIR, "**/*.prompt.md")).sort
        prompts.reject! { |p| p.include?("file_analysis.prompt.md") }

        debug_log "Found #{prompts.length} prompts to process"
        prompts.each { |p| debug_log "  - #{p}" } if @debug

        @prompt_runner.run(prompts, summary, output_root, additional_instructions: analysis_result)

        puts "\n✅ Migration complete! Assets generated in #{output_root}/"
      end

      def run_analysis(summary, output_root)
        path = File.join(PROMPTS_DIR, "file_analysis.prompt.md")
        return nil unless File.exist?(path)

        @processor.process(path, summary, output_root)
      end

      def find_exported_md(org_data)
        output_dir = Config.output_dir(@org_ref, org_data["name"])
        org_name = Utils.sanitize_filename(org_data["name"])
        path = File.join(output_dir, "#{@org_ref}_#{org_name}_#{@language}.md")
        return path if File.exist?(path)

        Dir.glob(File.join(output_dir, "#{@org_ref}_*_#{@language}.md")).first
      end

      def strip_markdown_fences(text)
        # Remove markdown code fences and trim whitespace
        if text =~ /```(?:markdown)?\n?(.*?)\n?```/m
          Regexp.last_match(1).strip
        else
          text.strip
        end
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
