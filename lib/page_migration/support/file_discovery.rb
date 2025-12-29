# frozen_string_literal: true

module PageMigration
  module Support
    # Centralized file discovery for query results and exports
    class FileDiscovery
      class << self
        def find_query_json(org_ref)
          pattern = File.join(Config.output_root, "#{org_ref}_*", Config::QUERY_JSON)
          Dir.glob(pattern).first
        end

        def find_query_json!(org_ref)
          find_query_json(org_ref) || raise(FileNotFoundError.new("No query.json for #{org_ref}"))
        end

        def find_latest_query_json
          pattern = File.join(Config.output_root, "*_*", Config::QUERY_JSON)
          Dir.glob(pattern).max_by { |f| File.mtime(f) }
        end

        def find_latest_query_json!
          find_latest_query_json || raise(FileNotFoundError.new("No query.json files found"))
        end

        def find_simple_json_content(org_ref, org_name, language)
          path = File.join(Config.output_root, "#{org_ref}_#{org_name}", "contenu_#{language}.json")
          return path if File.exist?(path)

          Dir.glob(File.join(Config.output_root, "#{org_ref}_*", "contenu_#{language}.json")).first
        end

        def find_simple_json_content!(org_ref, org_name, language)
          find_simple_json_content(org_ref, org_name, language) ||
            raise(FileNotFoundError.new("No content file for #{org_ref} (#{language})"))
        end

        def find_legacy_json(org_ref)
          path = File.join(Config.output_root, "#{org_ref}_organization.json")
          path if File.exist?(path)
        end
      end
    end
  end
end
