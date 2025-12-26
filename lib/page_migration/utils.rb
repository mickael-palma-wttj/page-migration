# frozen_string_literal: true

module PageMigration
  # Shared utility methods used across the application
  module Utils
    module_function

    # Converts a name to a safe filename slug
    # @param name [String] the name to sanitize
    # @return [String] lowercase slug with underscores
    def sanitize_filename(name)
      name.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
    end

    # Checks if a value is nil or empty after stripping whitespace
    # @param value [Object] the value to check
    # @return [Boolean] true if empty or nil
    def empty_value?(value)
      value.nil? || value.to_s.strip.empty?
    end
  end
end
