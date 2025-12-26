# frozen_string_literal: true

require "pg"
require "dotenv"

module PageMigration
  # Handles database connection
  class Database
    def self.connect
      Dotenv.load(".env")

      database_url = ENV["DATABASE_URL"] || raise(PageMigration::Error, "DATABASE_URL not set in .env file")
      PG.connect(database_url)
    end
  end
end
