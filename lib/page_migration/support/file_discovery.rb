# frozen_string_literal: true

module PageMigration
  module Support
    # Centralized file discovery for query results and exports
    class FileDiscovery
      def self.find_query_json(org_ref)
        pattern = File.join(Config::Config::QUERY_RESULT_DIR, "#{org_ref}_*", "query.json")
        Dir.glob(pattern).first
      end

      def self.find_query_json!(org_ref)
        find_query_json(org_ref) || raise(PageMigration::Error, "No query.json for #{org_ref}")
      end

      def self.find_latest_query_json
        pattern = File.join(Config::QUERY_RESULT_DIR, "*", "query.json")
        Dir.glob(pattern).max_by { |f| File.mtime(f) }
      end

      def self.find_text_content(org_ref, org_name, language)
        path = File.join(Config::QUERY_RESULT_DIR, "#{org_ref}_#{org_name}", "contenu_#{language}.txt")
        return path if File.exist?(path)

        Dir.glob(File.join(Config::QUERY_RESULT_DIR, "#{org_ref}_*", "contenu_#{language}.txt")).first
      end

      def self.find_legacy_json(org_ref)
        path = "tmp/#{org_ref}_organization.json"
        path if File.exist?(path)
      end
    end
  end
end
