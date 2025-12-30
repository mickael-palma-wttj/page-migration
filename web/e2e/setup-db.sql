-- Setup script for e2e test database
-- Run with: psql -f e2e/setup-db.sql -d page_migration_test

CREATE TABLE IF NOT EXISTS organizations (
  reference VARCHAR(50) PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

-- Insert test organizations
INSERT INTO organizations (reference, name) VALUES
  ('TEST001', 'Test Organization'),
  ('DEMO123', 'Demo Company'),
  ('SAMPLE', 'Sample Corp')
ON CONFLICT (reference) DO UPDATE SET name = EXCLUDED.name;
