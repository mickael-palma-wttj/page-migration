# frozen_string_literal: true

require "bundler"

module PageMigration
  module Commands
    # Starts the Rails web application with foreman (server + background worker)
    class App
      DEFAULT_PORT = 3000

      def initialize(port: DEFAULT_PORT)
        @port = port
      end

      def call
        web_app_dir = File.expand_path("../../../web", __dir__)

        unless Dir.exist?(web_app_dir)
          abort "Error: Web application not found at #{web_app_dir}\n" \
                "Make sure the web/ directory exists."
        end

        puts "Starting Page Migration Web UI..."
        puts "  URL: http://127.0.0.1:#{@port}"
        puts "  Press Ctrl+C to stop"
        puts ""

        # Set environment variables for Rails
        ENV["PAGE_MIGRATION_ROOT"] = File.expand_path("../../..", __dir__)
        ENV["PORT"] = @port.to_s

        # Fix for macOS fork() crash with Objective-C runtime when using Solid Queue
        # Must be set before forking occurs
        ENV["OBJC_DISABLE_INITIALIZE_FORK_SAFETY"] = "YES" if RUBY_PLATFORM.include?("darwin")

        # Change to web directory and start with foreman
        Dir.chdir(web_app_dir) do
          # Check if bundle install is needed
          unless File.exist?("Gemfile.lock") && system("bundle check --quiet")
            puts "Installing web dependencies..."
            system("bundle install --quiet") || abort("Failed to install dependencies")
          end

          # Ensure foreman is installed
          unless system("gem list foreman -i --silent")
            puts "Installing foreman..."
            system("gem install foreman") || abort("Failed to install foreman")
          end

          # Run database migrations if needed
          system("bin/rails db:prepare --quiet 2>/dev/null")

          # Start with foreman (web server + background worker + CSS watcher)
          # Clear bundler env so foreman runs outside the CLI's bundle context
          Bundler.with_unbundled_env do
            exec("foreman", "start", "-f", "Procfile.dev")
          end
        end
      end
    end
  end
end
