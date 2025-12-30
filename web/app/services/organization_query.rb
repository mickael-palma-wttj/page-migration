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

    def stats(size: nil, limit: 50)
      PageMigration::Database.with_connection do |conn|
        result = conn.exec(stats_query)
        rows = result.map { |row| build_stats_row(row) }
        rows = rows.select { |r| r[:size_category] == size } if size.present?
        rows.first(limit)
      end
    rescue => e
      Rails.logger.error "[OrganizationQuery] Stats failed: #{e.message}"
      raise
    end

    private

    def stats_query
      <<~SQL
        WITH org_page_counts AS (
          SELECT
            wp.organization_id AS organization_id,
            COUNT(p.id) AS total_cms_pages,
            COUNT(p.id) FILTER (WHERE p.published_at IS NOT NULL) AS published_cms_pages,
            MAX(p.published_at) AS latest_published_at
          FROM public.website_organizations wp
          LEFT JOIN public.cms_pages p
            ON p.website_organization_id = wp.id
          GROUP BY wp.organization_id
        )
        SELECT
          o.reference AS organization_reference,
          o.name AS organization_name,
          COALESCE(opc.total_cms_pages, 0) AS total_cms_pages,
          COALESCE(opc.published_cms_pages, 0) AS published_cms_pages,
          opc.latest_published_at,
          CASE
            WHEN COALESCE(opc.total_cms_pages, 0) <= 2 THEN 'small'
            WHEN COALESCE(opc.total_cms_pages, 0) <= 10 THEN 'medium'
            ELSE 'big'
          END AS size_category
        FROM public.organizations o
        LEFT JOIN org_page_counts opc
          ON opc.organization_id = o.id
        ORDER BY total_cms_pages DESC, o.id ASC
      SQL
    end

    def build_stats_row(row)
      {
        reference: row["organization_reference"],
        name: row["organization_name"],
        total_pages: row["total_cms_pages"].to_i,
        published_pages: row["published_cms_pages"].to_i,
        latest_published_at: row["latest_published_at"],
        size_category: row["size_category"]
      }
    end

    def build_organization(row)
      {
        reference: row["reference"],
        name: row["name"]
      }
    end
  end
end
