# Commands

CLI command implementations. Each command is a class with a `call` method.

## Commands

### Extract

Extracts organization data from the database.

```bash
./bin/page_migration extract <org_ref> [options]
```

| Option | Description |
|--------|-------------|
| `-o, --output FILE` | Output file path |
| `-f, --format FORMAT` | Output format: `json` (default) or `text` |
| `-l, --language LANG` | Language for text format (default: `fr`) |

**Files:**
- `extract.rb` - Main extract command with JSON/text format support

### Tree

Extracts and displays the page tree hierarchy.

```bash
./bin/page_migration tree <org_ref> [options]
```

**Files:**
- `extract_tree.rb` - Extracts page tree to JSON
- `show_tree.rb` - Displays tree in terminal

### Export

Exports organization content as Markdown files.

```bash
./bin/page_migration export <org_ref> [options]
```

| Option | Description |
|--------|-------------|
| `-o, --output-dir DIR` | Output directory |
| `-l, --languages LANGS` | Comma-separated languages |
| `-c, --custom-only` | Export only custom pages |
| `-t, --tree` | Export as directory tree |

**Files:**
- `export.rb` - Markdown export command

### Convert

Converts JSON data to Markdown files.

```bash
./bin/page_migration convert [org_ref] [options]
```

**Files:**
- `convert.rb` - JSON to Markdown converter

### Run

Runs extract and convert in sequence.

```bash
./bin/page_migration run <org_ref> [options]
```

**Files:**
- `run.rb` - Pipeline runner

### Migrate

Generates AI assets using Dust API based on prompt templates.

```bash
./bin/page_migration migrate <org_ref> [options]
```

| Option | Description |
|--------|-------------|
| `-l, --language LANG` | Language for content generation (default: `fr`) |

**Files:**
- `migrate.rb` - AI migration workflow orchestrator
