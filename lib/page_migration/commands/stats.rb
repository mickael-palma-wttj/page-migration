# frozen_string_literal: true

module PageMigration
  module Commands
    # Displays organization statistics with page counts
    class Stats < Base
      QUERY = <<~SQL
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
          o.id AS organization_id,
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

      def initialize(limit: 50, size: nil, output: nil, debug: false)
        super(nil, debug: debug)
        @limit = limit
        @size = size
        @output = output
      end

      def call
        results = fetch_stats
        results = filter_by_size(results) if @size
        results = results.first(@limit) if @limit

        if @output
          write_csv(results)
        else
          print_table(results)
        end
      end

      private

      def fetch_stats
        Database.with_connection do |conn|
          conn.exec(QUERY).to_a
        end
      end

      def filter_by_size(results)
        results.select { |r| r["size_category"] == @size }
      end

      def print_table(results)
        puts format_header
        puts "-" * 120
        results.each { |row| puts format_row(row) }
        puts "-" * 120
        print_summary(results)
      end

      def format_header
        "ref        name                                      total    pub latest_published     size"
      end

      def format_row(row)
        format("%-10s %-40s %6s %6s %-20s %s",
          row["organization_reference"],
          truncate(row["organization_name"], 40),
          row["total_cms_pages"],
          row["published_cms_pages"],
          row["latest_published_at"]&.[](0..18) || "-",
          row["size_category"])
      end

      def truncate(str, max)
        (str.length > max) ? "#{str[0..max - 3]}..." : str
      end

      def print_summary(results)
        total = results.size
        by_size = results.group_by { |r| r["size_category"] }

        puts "\nSummary: #{total} organizations"
        %w[big medium small].each do |size|
          count = by_size[size]&.size || 0
          puts "  #{size}: #{count}"
        end
      end

      def write_csv(results)
        require "csv"

        CSV.open(@output, "w") do |csv|
          csv << %w[reference name total_pages published_pages latest_published size]
          results.each do |row|
            csv << [
              row["organization_reference"],
              row["organization_name"],
              row["total_cms_pages"],
              row["published_cms_pages"],
              row["latest_published_at"],
              row["size_category"]
            ]
          end
        end

        puts "Written #{results.size} organizations to #{@output}"
      end
    end
  end
end
