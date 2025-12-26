# frozen_string_literal: true

module PageMigration
  module Queries
    # SQL query to extract the page tree structure for an organization.
    #
    # This query builds a hierarchical view of CMS pages using the "ancestry" pattern,
    # where parent-child relationships are stored as path strings (e.g., "1/2/3").
    #
    # Ancestry Pattern:
    #   - Root pages have ancestry = NULL
    #   - Child pages store their ancestor chain as "parent_id/grandparent_id/..."
    #   - Depth is calculated by counting path segments
    #
    # Output Structure:
    #   {
    #     "export_date": "2024-01-15 10:30:00",
    #     "organization": { "reference": "Pg4eV6k", "name": "Acme Corp", "website": "wttj_fr" },
    #     "page_tree": [
    #       { "id": 1, "slug": "about", "depth": 0, "is_root": true, ... },
    #       { "id": 2, "slug": "team", "depth": 1, "is_root": false, "ancestry": "1", ... }
    #     ],
    #     "statistics": { "total_pages": 5, "root_pages": 2, "max_depth": 3 }
    #   }
    #
    # Parameters:
    #   $1 - Organization reference (e.g., 'Pg4eV6k')
    #
    # Returns:
    #   JSON object with organization info, flattened page tree, and statistics.
    module PageTreeSql
      SQL = <<~SQL
        -- CTE to flatten the page hierarchy with computed depth levels
        WITH page_hierarchy AS (
          SELECT
            p.id, p.slug, p.name, p.reference, p.status, p.position, p.ancestry, p.published_at,
            o.reference as org_reference, o.name as org_name, w.reference as website,

            -- Calculate tree depth from ancestry path
            -- ancestry="1/2/3" has 3 segments = depth 3, NULL ancestry = root (depth 0)
            CASE
              WHEN p.ancestry IS NULL THEN 0
              ELSE ARRAY_LENGTH(STRING_TO_ARRAY(p.ancestry, '/'), 1)
            END as depth

          FROM cms_pages p
          -- Join through website_organizations to get org context
          INNER JOIN website_organizations wo ON p.website_organization_id = wo.id
          INNER JOIN organizations o ON wo.organization_id = o.id
          INNER JOIN websites w ON wo.website_id = w.id
          -- Filter to WTTJ France and the specific organization
          WHERE w.reference = 'wttj_fr' AND w.kind = 'external_wttj' AND o.reference = $1
        )

        -- Build final JSON output with organization info, page tree, and stats
        SELECT json_build_object(
          'export_date', NOW()::text,

          -- Organization metadata (extracted from any row since all are the same org)
          'organization', json_build_object(
            'reference', (SELECT DISTINCT org_reference FROM page_hierarchy),
            'name', (SELECT DISTINCT org_name FROM page_hierarchy),
            'website', (SELECT DISTINCT website FROM page_hierarchy)
          ),

          -- Flattened page tree, ordered for hierarchical display
          -- ORDER BY: roots first (NULL ancestry), then by position, then alphabetically
          'page_tree', json_agg(
            json_build_object(
              'id', id, 'slug', slug, 'name', COALESCE(name, 'Untitled'),
              'reference', reference, 'status', status, 'position', position,
              'ancestry', ancestry, 'published_at', published_at::text,
              'depth', COALESCE(depth, 0), 'is_root', ancestry IS NULL
            ) ORDER BY ancestry NULLS FIRST, position, slug
          ),

          -- Summary statistics for quick overview
          'statistics', json_build_object(
            'total_pages', (SELECT COUNT(*) FROM page_hierarchy),
            'root_pages', (SELECT COUNT(*) FROM page_hierarchy WHERE ancestry IS NULL),
            'max_depth', (SELECT COALESCE(MAX(depth), 0) FROM page_hierarchy)
          )
        ) as tree_data
        FROM page_hierarchy
      SQL
    end
  end
end
