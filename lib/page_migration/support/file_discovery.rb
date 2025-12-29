# frozen_string_literal: true

module PageMigration
  module Support
    # Centralized file discovery for query results and exports
    class FileDiscovery
      class << self
        def find_query_json(org_ref)
          pattern = File.join(Config::OUTPUT_ROOT, "#{org_ref}_*", "query.json")
          Dir.glob(pattern).first
        end

        def find_query_json!(org_ref)
          find_query_json(org_ref) || raise(FileNotFoundError.new("No query.json for #{org_ref}"))
        end

        def find_latest_query_json
          pattern = File.join(Config::OUTPUT_ROOT, "*_*", "query.json")
          Dir.glob(pattern).max_by { |f| File.mtime(f) }
        end

        def find_latest_query_json!
          find_latest_query_json || raise(FileNotFoundError.new("No query.json files found"))
        end

        def find_text_content(org_ref, org_name, language)
          path = File.join(Config::OUTPUT_ROOT, "#{org_ref}_#{org_name}", "contenu_#{language}.txt")
          return path if File.exist?(path)

          Dir.glob(File.join(Config::OUTPUT_ROOT, "#{org_ref}_*", "contenu_#{language}.txt")).first
        end

        def find_text_content!(org_ref, org_name, language)
          find_text_content(org_ref, org_name, language) ||
            raise(FileNotFoundError.new("No text content for #{org_ref} (#{language})"))
        end

        def find_legacy_json(org_ref)
          path = "tmp/#{org_ref}_organization.json"
          path if File.exist?(path)
        end
      end
    end
  end
end
