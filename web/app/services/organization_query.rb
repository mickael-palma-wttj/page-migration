# frozen_string_literal: true

class OrganizationQuery
  class << self
    def search(query, limit: 50)
      return [] if query.blank?

      PageMigration::Database.with_connection do |conn|
        result = conn.exec_params(<<~SQL, ["%#{query}%", "%#{query}%", limit])
          SELECT reference, name
          FROM organizations
          WHERE name ILIKE $1 OR reference ILIKE $2
          ORDER BY name
          LIMIT $3
        SQL

        result.map { |row| build_organization(row) }
      end
    rescue => e
      Rails.logger.error "[OrganizationQuery] Search failed: #{e.message}"
      raise
    end

    def find_by_reference(reference)
      PageMigration::Database.with_connection do |conn|
        result = conn.exec_params(<<~SQL, [reference])
          SELECT reference, name
          FROM organizations
          WHERE reference = $1
          LIMIT 1
        SQL

        return nil if result.ntuples.zero?

        build_organization(result[0])
      end
    rescue => e
      Rails.logger.error "[OrganizationQuery] Find failed: #{e.message}"
      nil
    end

    private

    def build_organization(row)
      {
        reference: row["reference"],
        name: row["name"]
      }
    end
  end
end
