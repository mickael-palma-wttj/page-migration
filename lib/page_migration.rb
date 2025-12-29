# frozen_string_literal: true

require "zeitwerk"

# Only auto-load dotenv when not running inside Rails
# Rails web app handles its own env loading to avoid DATABASE_URL conflicts
unless defined?(Rails)
  require "dotenv/load"
end

loader = Zeitwerk::Loader.for_gem
loader.setup

# Main module for Page Migration CLI
module PageMigration
end
