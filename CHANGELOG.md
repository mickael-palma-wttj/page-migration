# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
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

### Fixed
- StreamingIO Zeitwerk autoloading (added IO acronym inflection)
- Foreman runs with unbundled env to avoid gem conflicts
- CLI tasks use `bundle exec` for proper Ruby version
