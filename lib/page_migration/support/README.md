# Support

Utility classes and helper modules for common operations.

## Components

### FileDiscovery (`file_discovery.rb`)

Centralized file discovery for query results and exports.

**Methods:**

| Method | Description |
|--------|-------------|
| `find_query_json(org_ref)` | Finds query.json for an organization |
| `find_query_json!(org_ref)` | Same as above, raises if not found |
| `find_latest_query_json` | Finds the most recently modified query.json |
| `find_text_content(org_ref, org_name, language)` | Finds text content export file |
| `find_legacy_json(org_ref)` | Finds legacy JSON format file |

**Usage:**

```ruby
path = PageMigration::Support::FileDiscovery.find_query_json("Pg4eV6k")
# => "tmp/query_result/Pg4eV6k_Company/query.json"

path = PageMigration::Support::FileDiscovery.find_query_json!("Pg4eV6k")
# Raises PageMigration::Error if not found
```

### JsonLoader (`json_loader.rb`)

Safe JSON file loading with error handling.

**Methods:**
- `JsonLoader.load(path)` - Loads and parses JSON file, returns organizations array

**Usage:**

```ruby
data = PageMigration::Support::JsonLoader.load("tmp/query_result/Pg4eV6k_Company/query.json")
org = data.first
```

## Directory Structure

Query results are stored in:
```
tmp/query_result/
└── {org_ref}_{org_name}/
    ├── query.json
    ├── page_tree.json
    └── contenu_{lang}.txt
```
