# frozen_string_literal: true

# Load the parent PageMigration library
# This allows the Rails app to use the same code as the CLI

PAGE_MIGRATION_ROOT = ENV["PAGE_MIGRATION_ROOT"] || File.expand_path("../../..", __dir__)

# Add PageMigration lib to load path
$LOAD_PATH.unshift(File.join(PAGE_MIGRATION_ROOT, "lib"))

# Parse parent .env but DON'T set DATABASE_URL globally
# This prevents Rails from using the PostgreSQL database (which would break Solid Queue)
parent_env = Dotenv.parse(File.join(PAGE_MIGRATION_ROOT, ".env"))

# Store DATABASE_URL for PageMigration to use (but NOT in ENV to avoid polluting Rails)
PAGE_MIGRATION_DATABASE_URL = parent_env["DATABASE_URL"]

# Set all other env vars (except DATABASE_URL which would override Rails SQLite config)
parent_env.except("DATABASE_URL").each { |k, v| ENV[k] ||= v }

# Require the PageMigration library
# Note: page_migration.rb checks `defined?(Rails)` and skips dotenv/load when in Rails
require "page_migration"

# Eager load error classes to ensure they're available
require "page_migration/errors"

Rails.logger.info "[PageMigration] Loaded from #{PAGE_MIGRATION_ROOT}"
