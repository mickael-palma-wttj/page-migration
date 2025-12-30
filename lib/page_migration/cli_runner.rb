# frozen_string_literal: true

require "optparse"

module PageMigration
  # CLI parser and dispatcher
  class CliRunner
    COMMANDS = %w[extract tree export migrate health app stats].freeze
    HELP_TEXT = <<~HELP
      Page Migration CLI

      Usage: page_migration <command> [options]

      Commands:
        extract       Extract organization data from database (JSON or simple-json format)
        tree          Extract page tree hierarchy to JSON
        export        Export complete content as Markdown (one file per language)
        migrate       Generate assets using Dust AI (supports --agent-id for model selection)
        health        Check environment configuration and connectivity
        app           Start the web interface
        stats         Show organization statistics with page counts

      Options:
        -h, --help    Show help for a command

      Examples:
        page_migration extract Pg4eV6k                    # Extract org data to JSON
        page_migration extract Pg4eV6k -o custom.json     # Extract to custom file
        page_migration extract Pg4eV6k -f text            # Extract as plain text
        page_migration extract Pg4eV6k -f text -l en      # Extract text in English
        page_migration tree Pg4eV6k                       # Extract and display page tree
        page_migration tree Pg4eV6k -o tree.json          # Extract to custom file
        page_migration export Pg4eV6k                     # Export content (fr, en)
        page_migration export Pg4eV6k -l fr,en,cs         # Export specific languages
        page_migration export Pg4eV6k --custom-only       # Export only custom pages
        page_migration export Pg4eV6k --tree              # Export as directory tree
        page_migration migrate Pg4eV6k                    # Generate AI assets (uses exported MD)
        page_migration migrate Pg4eV6k -l en              # Generate AI assets using English source
        page_migration migrate Pg4eV6k --agent-id gpt5    # Use a specific AI model
        page_migration migrate Pg4eV6k --analysis         # Run page migration fit analysis only
        page_migration migrate Pg4eV6k --dry-run          # Preview migration without changes
        page_migration health                              # Verify environment setup
        page_migration app                                 # Start web UI on port 3000
        page_migration app -p 4000                         # Start web UI on custom port
        page_migration stats                               # Show organization page counts
        page_migration stats -s big                        # Show only big organizations
        page_migration stats -o orgs.csv                   # Export to CSV
    HELP

    def initialize(args)
      @args = args
      @options = {}
    end

    def call
      return show_help if @args.empty? || @args.first == "-h" || @args.first == "--help"

      command = @args.shift
      return show_help("Unknown command: #{command}") unless COMMANDS.include?(command)

      send("run_#{command}")
    end

    private

    def run_extract
      parser = build_extract_parser
      parser.parse!(@args)

      org_ref = validate_org_ref(@args.shift, parser)
      @options[:format] = Validator.validate_format!(@options[:format])
      @options[:language] = Validator.validate_language!(@options[:language])

      Commands::Extract.new(org_ref, **@options).call
    rescue Errors::ValidationError => e
      abort "Error: #{e.message}"
    end

    def build_extract_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration extract <org_reference> [options]"
        opts.on("-o", "--output FILE", "Output file") { |v| @options[:output] = v }
        opts.on("-f", "--format FORMAT", "Output format: json or simple-json") { |v| @options[:format] = v }
        opts.on("-l", "--language LANG", "Language for content export (default: fr)") { |v| @options[:language] = v }
        opts.on("-h", "--help", "Show this help") { |_| puts opts and exit }
      end
    end

    def run_tree
      parser = build_tree_parser
      parser.parse!(@args)

      org_ref = validate_org_ref(@args.shift, parser)

      Commands::ExtractTree.new(org_ref, **@options).call
    rescue Errors::ValidationError => e
      abort "Error: #{e.message}"
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
      parser = build_export_parser
      parser.parse!(@args)

      org_ref = validate_org_ref(@args.shift, parser)
      languages = @options[:languages]&.split(",")
      @options[:languages] = Validator.validate_languages!(languages)

      Commands::Export.new(org_ref, **@options.compact).call
    rescue Errors::ValidationError => e
      abort "Error: #{e.message}"
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
        opts.on("-h", "--help", "Show this help") { |_| puts opts and exit }
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
        opts.on("-h", "--help", "Show this help") { |_| puts opts and exit }
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
        opts.on("-h", "--help", "Show this help") { |_| puts opts and exit }
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
        opts.on("-h", "--help", "Show this help") { |_| puts opts and exit }
      end
    end

    def show_help(error = nil)
      puts "Error: #{error}\n\n" if error
      puts HELP_TEXT
    end

    def validate_org_ref(org_ref, parser)
      Validator.validate_org_ref!(org_ref)
    rescue Errors::ValidationError => e
      abort "Error: #{e.message}\n\n#{parser}"
    end
  end
end
