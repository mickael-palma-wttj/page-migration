ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# Remove DATABASE_URL to ensure Rails uses database.yml (SQLite)
# The parent PageMigration library sets this for PostgreSQL access,
# but Rails should use its own SQLite configuration
ENV.delete("DATABASE_URL")

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
