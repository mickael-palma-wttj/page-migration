# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- `stats` CLI command to show organization page count statistics
- Organization stats page in web UI with:
  - Summary cards (total, big, medium, small counts)
  - Sortable table columns (click headers to sort)
  - Size category filtering
  - CSV export
  - Clickable rows linking to organization details
  - Quick action button to run commands per organization
- `StatsFilterable` controller concern for parameter sanitization
- `OrganizationStat` model with domain logic
- `OrganizationStatPresenter` for view formatting
- `.tool-versions` for asdf compatibility
- Playwright e2e testing for web application
- VS Code tasks for common development workflows
- E2E tests integrated into CI pipeline with PostgreSQL
- Devcontainer support for Playwright
- Card-style command selection in web UI (matching Quick Actions)
- Organization model extracted from controller

### Changed
- Compare button now only shows for migrate command exports
- Consolidated CI workflows to root `.github/workflows/ci.yml`
- Web views refactored with presenters for cleaner code
- Ignore generated Tailwind CSS build artifacts

### Fixed
- StreamingIO Zeitwerk autoloading (added IO acronym inflection)
- Foreman runs with unbundled env to avoid gem conflicts
- CLI tasks use `bundle exec` for proper Ruby version
- CSV MIME type registration for Rails 8
