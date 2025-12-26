# Queries

SQL query definitions for extracting data from the database.

## Components

### OrganizationSQL (`organization_sql.rb`)

SQL query for extracting complete organization data including:
- Organization details
- Pages and content blocks
- Content items and properties
- Associated records (offices, images, videos, etc.)

Used by: `Extract` command, `OrganizationQuery`

### PageTreeSQL (`page_tree_sql.rb`)

SQL query for extracting the page hierarchy tree structure.

Used by: `ExtractTree` command, `PageTreeQuery`

## Query Classes

The SQL modules are used by corresponding query classes in the parent directory:

- `organization_query.rb` - Executes organization SQL and formats results
- `page_tree_query.rb` - Executes page tree SQL and formats results

## Database Connection

Queries use the `Database` class for connection management:

```ruby
conn = PageMigration::Database.connect
result = PageMigration::OrganizationQuery.new(org_ref).call(conn)
conn.close
```
