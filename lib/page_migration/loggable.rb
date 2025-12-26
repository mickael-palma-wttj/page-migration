# frozen_string_literal: true

module PageMigration
  # Shared logging functionality for debug output
  module Loggable
    def debug_log(message)
      puts "[DEBUG] #{message}" if @debug
    end
  end
end
