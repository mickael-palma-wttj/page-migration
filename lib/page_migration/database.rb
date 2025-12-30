# frozen_string_literal: true

require "pg"
require "dotenv"

module PageMigration
  # Handles database connection with automatic cleanup
  class Database
    def self.connect
      database_url = resolve_database_url
      PG.connect(database_url)
    end

    # Yields a connection and ensures it's closed after the block
    def self.with_connection
      conn = connect
      yield conn
    ensure
      conn&.close
    end

    # Resolve database URL from various sources
    # Priority: PAGE_MIGRATION_DATABASE_URL constant (Rails context) > ENV > .env file
    def self.resolve_database_url
      # In Rails context, use the constant set by the initializer
      if defined?(PAGE_MIGRATION_DATABASE_URL) && PAGE_MIGRATION_DATABASE_URL
        return PAGE_MIGRATION_DATABASE_URL
      end

      # In CLI context, load from .env file
      Dotenv.load(".env")
      ENV["DATABASE_URL"] || raise(PageMigration::Error, "DATABASE_URL not set in .env file")
    end
  end
end
