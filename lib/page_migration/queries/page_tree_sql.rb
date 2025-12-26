# frozen_string_literal: true

module PageMigration
  module Queries
    module PageTreeSql
      SQL = <<~SQL
        WITH page_hierarchy AS (
          SELECT
            p.id, p.slug, p.name, p.reference, p.status, p.position, p.ancestry, p.published_at,
            o.reference as org_reference, o.name as org_name, w.reference as website,
            CASE
              WHEN p.ancestry IS NULL THEN 0
              ELSE ARRAY_LENGTH(STRING_TO_ARRAY(p.ancestry, '/'), 1)
            END as depth
          FROM cms_pages p
          INNER JOIN website_organizations wo ON p.website_organization_id = wo.id
          INNER JOIN organizations o ON wo.organization_id = o.id
          INNER JOIN websites w ON wo.website_id = w.id
          WHERE w.reference = 'wttj_fr' AND w.kind = 'external_wttj' AND o.reference = $1
        )
        SELECT json_build_object(
          'export_date', NOW()::text,
          'organization', json_build_object(
            'reference', (SELECT DISTINCT org_reference FROM page_hierarchy),
            'name', (SELECT DISTINCT org_name FROM page_hierarchy),
            'website', (SELECT DISTINCT website FROM page_hierarchy)
          ),
          'page_tree', json_agg(
            json_build_object(
              'id', id, 'slug', slug, 'name', COALESCE(name, 'Untitled'),
              'reference', reference, 'status', status, 'position', position,
              'ancestry', ancestry, 'published_at', published_at::text,
              'depth', COALESCE(depth, 0), 'is_root', ancestry IS NULL
            ) ORDER BY ancestry NULLS FIRST, position, slug
          ),
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
