# frozen_string_literal: true

require "optparse"

module PageMigration
  # CLI parser and dispatcher
  class CliRunner
    COMMANDS = %w[extract tree export convert run migrate health].freeze
    HELP_TEXT = <<~HELP
      Page Migration CLI

      Usage: page_migration <command> [options]

      Commands:
        extract       Extract organization data from database (JSON or text format)
        tree          Extract page tree hierarchy to JSON
        export        Export complete content as Markdown (one file per language)
        convert       Convert JSON data to Markdown files
        run           Run both extract and convert in sequence
        migrate       Generate assets using Dust AI based on prompts
        health        Check environment configuration and connectivity

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
        page_migration convert                            # Convert default JSON to Markdown
        page_migration convert -i data.json -o output/    # Custom input and output
        page_migration run Pg4eV6k                        # Full pipeline
        page_migration migrate Pg4eV6k                    # Generate AI assets (uses exported MD)
        page_migration migrate Pg4eV6k -l en              # Generate AI assets using English source
        page_migration migrate Pg4eV6k --analysis         # Run page migration fit analysis only
        page_migration migrate Pg4eV6k --dry-run          # Preview migration without changes
        page_migration health                              # Verify environment setup
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
        opts.on("-f", "--format FORMAT", "Output format: json (default) or text") { |v| @options[:format] = v }
        opts.on("-l", "--language LANG", "Language for text format (default: fr)") { |v| @options[:language] = v }
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

    def run_convert
      parser = build_convert_parser
      parser.parse!(@args)

      org_ref = @args.shift

      Commands::Convert.new(org_ref, **@options).call
    end

    def build_convert_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration convert [org_ref] [options]"
        opts.on("-i", "--input FILE", "Input JSON file") { |v| @options[:input] = v }
        opts.on("-o", "--output-dir DIR", "Output directory") { |v| @options[:output_dir] = v }
        opts.on("-h", "--help", "Show this help") { |_| puts opts and exit }
      end
    end

    def run_run
      parser = build_run_parser
      parser.parse!(@args)

      org_ref = validate_org_ref(@args.shift, parser)

      Commands::Run.new(org_ref, **@options).call
    rescue Errors::ValidationError => e
      abort "Error: #{e.message}"
    end

    def build_run_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: page_migration run <org_reference> [options]"
        opts.on("-h", "--help", "Show this help") { |_| puts opts and exit }
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
        opts.on("-a", "--analysis", "Run page migration fit analysis only") { @options[:analysis] = true }
        opts.on("-n", "--dry-run", "Show what would be done without making changes") { @options[:dry_run] = true }
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
