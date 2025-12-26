# frozen_string_literal: true

module PageMigration
  # Centralized configuration for the application
  module Config
    # Dust API settings
    DEFAULT_TIMEOUT = ENV.fetch("DUST_TIMEOUT", 300).to_i

    # Content processing settings
    MAX_FRAGMENT_SIZE = ENV.fetch("MAX_FRAGMENT_SIZE", 500_000).to_i # ~500KB to stay under Dust 512KB limit

    # Parallel processing settings
    WORKER_COUNT = ENV.fetch("WORKER_COUNT", 5).to_i

    # Output directories
    EXPORT_DIR = "tmp/export"
    ANALYSIS_DIR = "tmp/analysis"
    QUERY_RESULT_DIR = "tmp/query_result"
    GENERATED_ASSETS_DIR = "tmp/generated_assets"
  end
end
