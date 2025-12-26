# Generators

Content generators for exporting organization data in various formats.

## Components

### FullExportGenerator (`full_export_generator.rb`)

Generates a complete Markdown export with tree view and all page content.

**Features:**
- Hierarchical tree visualization
- Page content with metadata tables
- Statistics summary
- Custom pages filter support

**Usage:**

```ruby
generator = PageMigration::Generators::FullExportGenerator.new(
  org_data,
  tree_data,
  language: "fr",
  custom_only: false
)
content = generator.generate
```

### TreeExportGenerator (`tree_export_generator.rb`)

Generates a hierarchical directory structure with one Markdown file per page.

**Features:**
- Creates nested folder structure matching page hierarchy
- Each page becomes an `index.md` file
- Preserves page metadata and content blocks

**Usage:**

```ruby
generator = PageMigration::Generators::TreeExportGenerator.new(
  org_data,
  tree_data,
  language: "fr",
  output_dir: "tmp/export/tree",
  custom_only: false
)
generator.generate
```

### TextContentGenerator (`text_content_generator.rb`)

Generates plain text content export for AI processing.

**Features:**
- Extracts translatable text content
- Language-specific property extraction
- Clean text format for LLM consumption

**Usage:**

```ruby
generator = PageMigration::Generators::TextContentGenerator.new(
  org_data,
  language: "fr"
)
content = generator.generate
```

## Shared Modules

Generators include shared functionality from:
- `Renderers::ContentRenderer` - Property and block rendering
- `Renderers::TreeRenderer` - Tree visualization helpers
