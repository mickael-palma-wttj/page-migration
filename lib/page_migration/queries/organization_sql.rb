# frozen_string_literal: true

module PageMigration
  module Queries
    # SQL query to extract complete organization data with all nested content.
    #
    # This query builds a complete JSON export of an organization's CMS content:
    #
    # Data Model (simplified):
    #   Organization
    #     └── WebsiteOrganization (links org to a website like wttj_fr)
    #           └── CmsPages (company profile pages: about, team, etc.)
    #                 └── CmsBlocks (content sections within a page)
    #                       └── CmsContents (individual content items)
    #                             └── Records (images, videos, offices, etc.)
    #
    # The query uses nested json_agg() to build the hierarchy in a single query,
    # avoiding N+1 queries. Each content item can reference different record types
    # (polymorphic association), which are resolved via CASE statements.
    #
    # Parameters:
    #   $1 - Organization reference (e.g., 'Pg4eV6k')
    #
    # Returns:
    #   JSON object with export_date and organizations array containing
    #   the full page/block/content hierarchy for the organization.
    module OrganizationSql
      SQL = <<~SQL
        -- CTE to gather organization data with all pages and nested content
        WITH org_pages AS (
          SELECT
            o.id,
            o.reference,
            o.name,
            o.created_at,
            o.updated_at,
            w.reference as website,

            -- Aggregate all pages for this organization into a JSON array
            json_agg(
              json_build_object(
                'id', p.id,
                'slug', p.slug,
                'reference', p.reference,
                'name', p.name,
                'status', p.status,
                'position', p.position,
                'created_at', p.created_at::text,

                -- Nested subquery: get all content blocks for this page
                'content_blocks', (
                  SELECT json_agg(
                    json_build_object(
                      'id', b.id,
                      'position', b.position,
                      'kind', b.kind,
                      'created_at', b.created_at::text,

                      -- Nested subquery: get all content items within this block
                      'content_items', (
                        SELECT json_agg(
                          json_build_object(
                            'id', c.id,
                            'kind', c.kind,
                            'record_type', c.record_type,
                            'record_id', c.record_id,
                            'position', c.position,
                            'properties', c.properties,  -- JSON field with localized content

                            -- Polymorphic record resolution: fetch related record data
                            -- based on record_type (Cms::Image, Cms::Video, Office, etc.)
                            'record', CASE#{" "}
                              WHEN c.record_type = 'Cms::Image' THEN (
                                SELECT json_build_object(
                                  'file', img.file,
                                  'name', img.name,
                                  'description', img.description
                                ) FROM cms_images img WHERE img.id = c.record_id::bigint
                              )
                              WHEN c.record_type = 'Cms::Video' THEN (
                                SELECT json_build_object(
                                  'source', v.source,
                                  'external_reference', v.external_reference,
                                  'name', v.name,
                                  'description', v.description,
                                  'image', v.image
                                ) FROM cms_videos v WHERE v.id = c.record_id::bigint
                              )
                              WHEN c.record_type = 'Organization' THEN (
                                SELECT json_build_object(
                                  'reference', org.reference,
                                  'name', org.name
                                ) FROM organizations org WHERE org.id = c.record_id::bigint
                              )
                              WHEN c.record_type = 'Office' THEN (
                                SELECT json_build_object(
                                  'name', ofc.name,
                                  'address', ofc.address,
                                  'city', ofc.city,
                                  'country_code', ofc.country_code
                                ) FROM offices ofc WHERE ofc.id = c.record_id::bigint
                              )
                              WHEN c.record_type = 'WebsiteOrganization' THEN (
                                SELECT json_build_object(
                                  'organization_reference', org2.reference,
                                  'organization_name', org2.name
                                ) FROM website_organizations wo2
                                JOIN organizations org2 ON wo2.organization_id = org2.id
                                WHERE wo2.id = c.record_id::bigint
                              )
                              ELSE NULL
                            END
                          ) ORDER BY c.position
                        )
                        FROM cms_contents c
                        WHERE c.cms_block_id = b.id
                      )
                    ) ORDER BY b.position
                  )
                  FROM cms_blocks b
                  -- Blocks belong to containers, which belong to website_organizations
                  WHERE b.cms_container_id IN (
                    SELECT id FROM cms_containers WHERE website_organization_id = wo.id
                  )
                )
              ) ORDER BY p.position
            ) as pages

          FROM organizations o
          -- Join through website_organizations to get the org's presence on a website
          INNER JOIN website_organizations wo ON o.id = wo.organization_id
          INNER JOIN websites w ON wo.website_id = w.id
          -- Left join pages (org may have no pages yet)
          LEFT JOIN cms_pages p ON wo.id = p.website_organization_id
          -- Filter to WTTJ France external website and specific org reference
          WHERE w.reference = 'wttj_fr' AND w.kind = 'external_wttj' AND o.reference = $1
          GROUP BY o.id, o.reference, o.name, o.created_at, o.updated_at, w.reference, wo.id
        )

        -- Final output: wrap everything in a single JSON object
        SELECT json_build_object(
          'export_date', NOW()::text,
          'organizations', json_agg(
            json_build_object(
              'id', id,
              'reference', reference,
              'name', name,
              'website', website,
              'created_at', created_at::text,
              'updated_at', updated_at::text,
              'pages', COALESCE(pages, '[]'::json)
            ) ORDER BY name
          )
        ) as data
        FROM org_pages;
      SQL
    end
  end
end
