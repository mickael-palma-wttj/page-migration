# Renderers

Shared rendering modules and utilities for content transformation.

## Components

### ContentRenderer (`content_renderer.rb`)

Mixin module providing shared content rendering methods.

**Methods:**
- `render_property(key, value, language)` - Renders a property value based on type
- `build_pages_index(org)` - Creates a hash lookup of pages by ID
- `build_tree_index(tree)` - Creates a hash lookup of tree pages by ID
- `find_children(tree, parent_id)` - Finds child pages for a given parent

**Usage:**

```ruby
class MyGenerator
  include PageMigration::Renderers::ContentRenderer

  def render
    render_property("body", { "fr" => "Bonjour" }, "fr")
  end
end
```

### TreeRenderer (`tree_renderer.rb`)

Mixin module for hierarchical tree visualization.

**Constants:**
- `CONNECTOR_LAST` - `└── `
- `CONNECTOR_MIDDLE` - `├── `
- `PREFIX_LAST` - `    `
- `PREFIX_MIDDLE` - `│   `
- `STATUS_PUBLISHED` - `✅`
- `STATUS_DRAFT` - `❌`

**Methods:**
- `tree_connector(is_last)` - Returns appropriate connector character
- `tree_prefix(current_prefix, is_last)` - Builds indentation prefix
- `status_icon(status)` - Returns status emoji

### RecordRenderer (`record_renderer.rb`)

Renders associated records (offices, images, videos, etc.) as Markdown.

**Supported Record Types:**
- Office
- Image
- Video
- Article
- Media
- Embed

**Usage:**

```ruby
renderer = PageMigration::Renderers::RecordRenderer.new(record, "Office")
markdown = renderer.render
```

### PageClassifier (`page_classifier.rb`)

Classifies pages as standard (WTTJ templates) or custom.

**Methods:**
- `PageClassifier.custom?(slug)` - Returns true if page is custom
- `PageClassifier.standard?(slug)` - Returns true if page is a WTTJ template

**Standard Page Slugs:**
- `/`, `/jobs`, `/team`, `/offices`
- `/about-us`, `/why-join-us`, `/what-we-do`
- `/news`, `/faq`, `/departments`
