# frozen_string_literal: true

module PageMigration
  module Queries
    module OrganizationSql
      SQL = <<~SQL
        WITH org_pages AS (
          SELECT
            o.id,
            o.reference,
            o.name,
            o.created_at,
            o.updated_at,
            w.reference as website,
            json_agg(
              json_build_object(
                'id', p.id,
                'slug', p.slug,
                'reference', p.reference,
                'name', p.name,
                'status', p.status,
                'position', p.position,
                'created_at', p.created_at::text,
                'content_blocks', (
                  SELECT json_agg(
                    json_build_object(
                      'id', b.id,
                      'position', b.position,
                      'kind', b.kind,
                      'created_at', b.created_at::text,
                      'content_items', (
                        SELECT json_agg(
                          json_build_object(
                            'id', c.id,
                            'kind', c.kind,
                            'record_type', c.record_type,
                            'record_id', c.record_id,
                            'position', c.position,
                            'properties', c.properties,
                            'record', CASE#{' '}
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
                  WHERE b.cms_container_id IN (
                    SELECT id FROM cms_containers WHERE website_organization_id = wo.id
                  )
                )
              ) ORDER BY p.position
            ) as pages
          FROM organizations o
          INNER JOIN website_organizations wo ON o.id = wo.organization_id
          INNER JOIN websites w ON wo.website_id = w.id
          LEFT JOIN cms_pages p ON wo.id = p.website_organization_id
          WHERE w.reference = 'wttj_fr' AND w.kind = 'external_wttj' AND o.reference = $1
          GROUP BY o.id, o.reference, o.name, o.created_at, o.updated_at, w.reference, wo.id
        )
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
