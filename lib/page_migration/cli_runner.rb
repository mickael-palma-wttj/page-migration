# frozen_string_literal: true

require "optparse"

module PageMigration
  # CLI parser and dispatcher
  class CliRunner
    COMMANDS = %w[extract tree export migrate health app stats].freeze
    HELP_TEXT = File.read(File.expand_path("cli_help.txt", __dir__)).freeze

    def initialize(args)
      @args = args
      @options = {}
    end

    def call
      return show_help if @args.empty? || help_requested?

      command = @args.shift
      return show_help("Unknown command: #{command}") unless COMMANDS.include?(command)

      send("run_#{command}")
    end

    private

    def run_extract
      run_with_org_ref(build_extract_parser) do |org_ref|
        @options[:format] = Validator.validate_format!(@options[:format])
        @options[:language] = Validator.validate_language!(@options[:language])
        Commands::Extract.new(org_ref, **@options).call
      end
    end

    def build_extract_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration extract <org_reference> [options]"
        opts.on("-o", "--output FILE", "Output file") { |v| @options[:output] = v }
        opts.on("-f", "--format FORMAT", "Output format: json or simple-json") { |v| @options[:format] = v }
        opts.on("-l", "--language LANG", "Language for content export (default: fr)") { |v| @options[:language] = v }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def run_tree
      run_with_org_ref(build_tree_parser) do |org_ref|
        Commands::ExtractTree.new(org_ref, **@options).call
      end
    end

    def build_tree_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration tree <org_ref> [options]"
        opts.on("-o", "--output FILE", "Output JSON file") { |f| @options[:output] = f }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def run_export
      run_with_org_ref(build_export_parser) do |org_ref|
        languages = @options[:languages]&.split(",")
        @options[:languages] = Validator.validate_languages!(languages)
        Commands::Export.new(org_ref, **@options.compact).call
      end
    end

    def build_export_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration export <org_ref> [options]"
        opts.on("-o", "--output-dir DIR", "Output directory") { |d| @options[:output_dir] = d }
        opts.on("-l", "--languages LANGS", "Languages (comma-separated: fr,en,cs)") { |l| @options[:languages] = l }
        opts.on("-c", "--custom-only", "Export only custom pages (exclude standard tabs)") do
          @options[:custom_only] = true
        end
        opts.on("-t", "--tree", "Export as a directory tree instead of a single file") do
          @options[:tree] = true
        end
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def run_migrate
      parser = build_migrate_parser
      parser.parse!(@args)

      org_ref = validate_org_ref(@args.shift, parser)
      @options[:language] = Validator.validate_language!(@options[:language])

      Commands::Migrate.new(org_ref, **@options).call
    rescue Errors::ValidationError => e
      abort "Error: #{e.message}"
    end

    def build_migrate_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration migrate <org_reference> [options]"
        opts.on("-l", "--language LANG", "Language for content generation (default: fr)") { |v| @options[:language] = v }
        opts.on("-m", "--agent-id MODEL", "AI model/agent ID (default: DUST_AGENT_ID env)") { |v| @options[:agent_id] = v }
        opts.on("-a", "--analysis", "Run page migration fit analysis only") { @options[:analysis] = true }
        opts.on("-n", "--dry-run", "Show what would be done without making changes") { @options[:dry_run] = true }
        opts.on("--no-cache", "Disable prompt caching (re-run all prompts)") { @options[:cache] = false }
        opts.on("-d", "--debug", "Enable debug mode with detailed output") { @options[:debug] = true }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def run_health
      parser = build_health_parser
      parser.parse!(@args)

      success = Commands::Health.new(**@options).call
      exit(1) unless success
    end

    def build_health_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration health [options]"
        opts.on("-d", "--debug", "Enable debug mode") { @options[:debug] = true }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def run_app
      parser = build_app_parser
      parser.parse!(@args)

      Commands::App.new(**@options).call
    end

    def build_app_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration app [options]"
        opts.on("-p", "--port PORT", Integer, "Port number (default: 3000)") { |p| @options[:port] = p }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def run_stats
      parser = build_stats_parser
      parser.parse!(@args)

      Commands::Stats.new(**@options).call
    end

    def build_stats_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration stats [options]"
        opts.on("-n", "--limit N", Integer, "Limit results (default: 50)") { |n| @options[:limit] = n }
        opts.on("-s", "--size SIZE", "Filter by size: small, medium, big") { |s| @options[:size] = s }
        opts.on("-o", "--output FILE", "Export to CSV file") { |f| @options[:output] = f }
        opts.on("-d", "--debug", "Enable debug mode") { @options[:debug] = true }
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def show_help(error = nil)
      puts "Error: #{error}\n\n" if error
      puts HELP_TEXT
    end

    def run_with_org_ref(parser)
      parser.parse!(@args)
      org_ref = validate_org_ref(@args.shift, parser)
      yield org_ref
    rescue Errors::ValidationError => e
      abort "Error: #{e.message}"
    end

    def validate_org_ref(org_ref, parser)
      Validator.validate_org_ref!(org_ref)
    rescue Errors::ValidationError => e
      abort "Error: #{e.message}\n\n#{parser}"
    end

    def help_requested?
      %w[-h --help].include?(@args.first)
    end
  end
end
