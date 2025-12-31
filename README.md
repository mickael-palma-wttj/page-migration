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

| Command    | Description                                              |
|------------|----------------------------------------------------------|
| `extract`  | Extract organization data from database (JSON or text)   |
| `tree`     | Extract page tree hierarchy to JSON                      |
| `export`   | Export complete content as Markdown                      |
| `migrate`  | Generate assets using Dust AI based on prompts           |
| `analysis` | Run AI-powered page migration fit analysis               |
| `health`   | Check environment configuration and connectivity         |
| `stats`    | Show organization page count statistics                  |
| `app`      | Start the web interface                                  |

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

# Export as directory tree
./bin/page_migration export Pg4eV6k --tree

# Generate AI assets using Dust
./bin/page_migration migrate Pg4eV6k

# Generate AI assets in English
./bin/page_migration migrate Pg4eV6k -l en

# Use a specific AI model
./bin/page_migration migrate Pg4eV6k --agent-id gpt5

# Run page migration fit analysis
./bin/page_migration migrate Pg4eV6k --analysis

# Preview migration without changes
./bin/page_migration migrate Pg4eV6k --dry-run

# Check environment setup
./bin/page_migration health

# Show organization statistics
./bin/page_migration stats

# Filter stats by size category
./bin/page_migration stats --size big

# Start web UI
./bin/page_migration app

# Start web UI on custom port
./bin/page_migration app -p 4000
```

## Web Application

The web application provides a user-friendly interface for running commands and viewing results.

```bash
# Start the web app
./bin/page_migration app

# Or directly with Rails
cd web && bin/rails server
```

Features:
- Organization search and selection
- Run extract, export, migrate, analysis, tree, and health commands
- Organization statistics with filtering, sorting, and CSV export
- View command history and results
- Compare migration outputs
- Real-time streaming output

### E2E Testing

The web app includes Playwright-based end-to-end tests:

```bash
cd web

# Run all e2e tests
npm test

# Run tests with UI
npm run test:ui

# Run tests in headed mode
npm run test:headed
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
    generators/              # Content export generators
    prompts/                 # AI prompt templates
    queries/                 # SQL query definitions
    renderers/               # Shared rendering modules
    services/                # Business logic services
    support/                 # Utility classes and helpers

web/                         # Rails web application
  app/
    controllers/             # Application controllers
    models/                  # Data models
    views/                   # ERB templates
    presenters/              # View presenters
  e2e/                       # Playwright tests
```

### Module Overview

| Directory | Purpose |
|-----------|---------|
| `commands/` | CLI command classes (extract, export, migrate, etc.) |
| `dust/` | Dust AI API client and conversation runner |
| `generators/` | Content generators (Markdown, text, tree exports) |
| `prompts/` | AI prompt templates for migration workflows |
| `queries/` | SQL queries for organization and page tree data |
| `renderers/` | Shared rendering logic (content, tree, records) |
| `services/` | Business logic (prompt processing, AI workflows) |
| `support/` | Utilities (file discovery, JSON loading) |

See README files in each subdirectory for detailed documentation.

## Output Locations

| Format | Default Path |
|--------|--------------|
| JSON   | `tmp/query_result/{org_ref}_{name}/query.json` |
| Text   | `tmp/query_result/{org_ref}_{name}/contenu_{lang}.txt` |
| Markdown | `tmp/export/{org_ref}_{name}_{lang}.md` |
| AI Assets | `tmp/generated_assets/{org_ref}_{name}/` |

## Development

### VS Code Tasks

Essential tasks are available via `Cmd+Shift+P` → "Tasks: Run Task":

**CLI:**
- CLI: Run App - Start the web interface
- CLI: Help - Show CLI help
- CLI: Run Tests - Run RSpec tests
- CLI: Run Linter / Fix Linting - StandardRB

**Web:**
- Web: Start Server - Rails development server
- Web: Run E2E Tests - Playwright tests
- Web: DB Migrate / Prepare - Database management
- Web: Rails Console - Interactive console

## License

Proprietary
