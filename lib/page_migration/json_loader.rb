# frozen_string_literal: true

require "json"

module PageMigration
  # Loads and parses JSON data from a file
  class JsonLoader
    def self.load(path)
      raise PageMigration::Error, "File not found: #{path}" unless File.exist?(path)

      raw_content = File.read(path)
      parse_data(raw_content)
    end

    def self.parse_data(content)
      data = JSON.parse(content)
      data = data["data"] if data.is_a?(Hash) && data.key?("data")
      data = JSON.parse(data) if data.is_a?(String)

      extract_organizations(data)
    end

    def self.extract_organizations(data)
      orgs = data["organizations"]
      orgs.is_a?(String) ? JSON.parse(orgs) : orgs
    end
  end
end
