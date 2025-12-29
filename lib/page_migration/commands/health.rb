# frozen_string_literal: true

module PageMigration
  module Commands
    # Verifies environment configuration and connectivity
    class Health < Base
      REQUIRED_ENV_VARS = %w[
        DATABASE_URL
        DUST_WORKSPACE_ID
        DUST_API_KEY
        DUST_AGENT_ID
      ].freeze

      def initialize(debug: false)
        super(nil, debug: debug)
      end

      def call
        puts "🔍 Checking environment configuration...\n\n"

        checks = [
          check_env_vars,
          check_database,
          check_dust_api
        ]

        puts "\n"
        if checks.all?
          puts "✅ All checks passed! Environment is ready."
          true
        else
          puts "❌ Some checks failed. Please fix the issues above."
          false
        end
      end

      private

      def check_env_vars
        puts "📋 Environment Variables:"
        all_present = true

        REQUIRED_ENV_VARS.each do |var|
          present = ENV.key?(var) && !ENV[var].to_s.empty?
          status = present ? "✓" : "✗"
          value_hint = present ? "(set)" : "(missing)"

          puts "   #{status} #{var} #{value_hint}"
          all_present = false unless present
        end

        all_present
      end

      def check_database
        puts "\n🗄️  Database Connection:"
        begin
          Database.with_connection do |conn|
            result = conn.exec("SELECT 1")
            puts "   ✓ Connected successfully"
            debug_log "Query result: #{result.values}"
          end
          true
        rescue PG::Error => e
          puts "   ✗ Connection failed: #{e.message}"
          false
        rescue => e
          puts "   ✗ Error: #{e.message}"
          false
        end
      end

      def check_dust_api
        puts "\n🤖 Dust API:"

        unless ENV["DUST_API_KEY"] && ENV["DUST_WORKSPACE_ID"]
          puts "   ⚠️  Skipped (missing credentials)"
          return true
        end

        begin
          # Just verify the client can be created (we don't want to make actual API calls)
          Dust::Client.new(
            ENV["DUST_WORKSPACE_ID"],
            ENV["DUST_API_KEY"],
            debug: @debug
          )

          puts "   ✓ Client configured"
          puts "   ℹ️  Workspace: #{ENV["DUST_WORKSPACE_ID"]}"
          true
        rescue => e
          puts "   ✗ Configuration error: #{e.message}"
          false
        end
      end
    end
  end
end
