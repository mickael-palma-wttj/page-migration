# frozen_string_literal: true

require "zeitwerk"
require "dotenv/load"

loader = Zeitwerk::Loader.for_gem
loader.setup

# Main module for Page Migration CLI
module PageMigration
  class Error < StandardError; end
end
