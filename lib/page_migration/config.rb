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

    # Output directories - can be overridden via environment variable or thread-local
    DEFAULT_OUTPUT_ROOT = "tmp"

    # Default filenames
    QUERY_JSON = "query.json"
    TREE_JSON = "tree.json"

    # Thread-local storage for output root override
    def self.output_root
      Thread.current[:page_migration_output_root] || ENV.fetch("PAGE_MIGRATION_OUTPUT_ROOT", DEFAULT_OUTPUT_ROOT)
    end

    def self.output_root=(path)
      Thread.current[:page_migration_output_root] = path
    end

    def self.with_output_root(path)
      old_root = Thread.current[:page_migration_output_root]
      Thread.current[:page_migration_output_root] = path
      yield
    ensure
      Thread.current[:page_migration_output_root] = old_root
    end

    def self.output_dir(org_ref, org_name)
      slug = Utils.sanitize_filename(org_name)
      File.join(output_root, "#{org_ref}_#{slug}")
    end

    def self.query_json_path(org_ref, org_name)
      File.join(output_dir(org_ref, org_name), QUERY_JSON)
    end

    def self.tree_json_path(org_ref, org_name)
      File.join(output_dir(org_ref, org_name), TREE_JSON)
    end
  end
end
