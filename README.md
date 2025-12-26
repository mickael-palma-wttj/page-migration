# Page Migration CLI

A Ruby CLI tool for extracting, exporting, and migrating organization page content using the Dust AI API.

## Installation

```bash
bundle install
```

## Configuration

Create a `.env` file with the following variables:

```env
DATABASE_URL=postgres://user:password@host:port/database
DUST_WORKSPACE_ID=your_workspace_id
DUST_API_KEY=your_api_key
DUST_AGENT_ID=your_agent_id
```

## Usage

```bash
./bin/page_migration <command> [options]
```

### Commands

| Command   | Description                                              |
|-----------|----------------------------------------------------------|
| `extract` | Extract organization data from database (JSON or text)  |
| `tree`    | Extract page tree hierarchy to JSON                     |
| `export`  | Export complete content as Markdown                     |
| `convert` | Convert JSON data to Markdown files                     |
| `run`     | Run both extract and convert in sequence                |
| `migrate` | Generate assets using Dust AI based on prompts          |

### Examples

```bash
# Extract organization data to JSON
./bin/page_migration extract Pg4eV6k

# Extract as plain text (for AI processing)
./bin/page_migration extract Pg4eV6k -f text

# Extract text in English
./bin/page_migration extract Pg4eV6k -f text -l en

# Export content as Markdown
./bin/page_migration export Pg4eV6k

# Export specific languages
./bin/page_migration export Pg4eV6k -l fr,en,cs

# Export only custom pages
./bin/page_migration export Pg4eV6k --custom-only

# Generate AI assets using Dust
./bin/page_migration migrate Pg4eV6k

# Generate AI assets in English
./bin/page_migration migrate Pg4eV6k -l en
```

## Project Structure

```
lib/
  page_migration.rb          # Main module entry point
  page_migration/
    cli_runner.rb            # CLI parser and dispatcher
    database.rb              # Database connection helper
    commands/                # CLI command implementations
    dust/                    # Dust API client and runner
    queries/                 # SQL query definitions
    services/                # Business logic services
```

See README files in each subfolder for detailed documentation.

## Output Locations

| Format | Default Path |
|--------|--------------|
| JSON   | `tmp/query_result/{org_ref}_{name}/query.json` |
| Text   | `tmp/query_result/{org_ref}_{name}/contenu_{lang}.txt` |
| Markdown | `tmp/export/{org_ref}_{name}_{lang}.md` |
| AI Assets | `tmp/generated_assets/{org_ref}_{name}/` |

## License

Proprietary
