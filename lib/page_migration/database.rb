# frozen_string_literal: true

require "pg"
require "dotenv"

module PageMigration
  # Handles database connection with automatic cleanup
  class Database
    def self.connect
      Dotenv.load(".env")

      database_url = ENV["DATABASE_URL"] || raise(PageMigration::Error, "DATABASE_URL not set in .env file")
      PG.connect(database_url)
    end

    # Yields a connection and ensures it's closed after the block
    def self.with_connection
      conn = connect
      yield conn
    ensure
      conn&.close
    end
  end
end
