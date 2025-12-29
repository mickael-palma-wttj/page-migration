# frozen_string_literal: true

# Configure Solid Queue to use the queue database
# This is important because we have a dual-database setup:
# - SQLite for Rails (primary + queue)
# - PostgreSQL for PageMigration (external, read-only)

SolidQueue.connects_to = {database: {writing: :queue}}
