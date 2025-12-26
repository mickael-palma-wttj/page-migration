# Page Migration Fit Analysis Method

## Overview

This document describes the methodology used to analyze organization career pages for migration to standardized templates. The goal is to determine which custom pages can be consolidated into target templates, which should be archived, and estimate the page reduction potential.

---

## 1. Data Extraction

### Step 1.1: Export Organization Data

Use the `page-migration` CLI tool to export organization data:

```bash
bin/page_migration export <org_reference> --custom-only
```

Or run the SQL query directly to get full page structure with blocks and content.

### Step 1.2: Extract Key Metrics

From the exported JSON, extract:

```bash
# Organization info
jq '{name: .organizations[0].name, reference: .organizations[0].reference, page_count: (.organizations[0].pages | length)}'

# Page listing with status and block counts
jq -r '.organizations[0].pages[] | "\(.slug)\t\(.status)\t\(.content_blocks | length)"'
```

### Step 1.3: Identify Architecture Type

Check if pages have unique or shared blocks:

```bash
# Compare block IDs across pages
jq -c '.organizations[0].pages[:3] | .[] | {slug: .slug, first_5_block_ids: [.content_blocks[:5][].id]}'
```

**Two patterns observed:**
- **Unique blocks per page**: Each page has distinct content blocks (traditional CMS)
- **Shared blocks across pages**: All pages reference the same block pool (pseudo-SPA architecture) - requires slug-based analysis

---

## 2. Page Classification

### Step 2.1: Identify Standard Pages

Standard pages follow known WTTJ patterns and don't need migration:

| Pattern | Slug Examples | Notes |
|---------|---------------|-------|
| Profile/Home | `/` | Main career page |
| Jobs | `/jobs` | Job listings |
| Meetings | `/meetings` | Recruitment events |
| Teams | `/team`, `/team-1` | Team showcase |
| Benefits | `/les-plus`, `/avantages` | Standard benefits page |

### Step 2.2: Classify Custom Pages by Slug Semantics

Analyze page slugs to determine intent and map to target templates:

| Slug Pattern | Likely Purpose | Target Template |
|--------------|----------------|-----------------|
| `/paris`, `/lyon`, `/bordeaux`, city names | Office locations | **Offices and Remote policy** |
| `/region-*`, geographic names | Regional offices | **Offices and Remote policy** |
| `/metiers-*`, `/nos-metiers` | Career paths/departments | **Teams** |
| `/consultant-*`, `/ingenieur-*`, job titles | Role descriptions | **Teams** |
| `/culture`, `/vie-*`, `/ambiance` | Company culture | **Culture & Story** |
| `/engagements`, `/csr`, `/rse` | CSR commitments | **CSR** |
| `/diversite`, `/inclusion`, `/dei` | DEI initiatives | **DEI** |
| `/alternance`, `/stages`, `/jeunes-talents` | Early career | **Students** |
| `/avantages`, `/benefits`, `/qvct` | Employee perks | **Perks and Benefits** |
| `/tech`, `/it-*`, `/digital`, `/ia` | Tech content | **Tech Department** |
| `/entites`, `/filiales`, brand names | Subsidiaries | **Subsidiaries** |
| `/notre-entreprise`, `/about`, `/histoire` | Company info | **About Us** |

### Step 2.3: Identify Draft/Archive Candidates

Pages to archive:
- Status = `draft` (unpublished)
- Status = `to_validate` (review before deciding)
- Slugs with `_old` suffix (deprecated)
- Duplicate content (e.g., `/team` draft when `/team-1` is published)

---

## 3. Target Templates

### Available Templates

| Template | Purpose | Common Content |
|----------|---------|----------------|
| **Culture & Story** | Company culture, values, history | Vision, mission, work atmosphere |
| **Offices and Remote policy** | Locations, remote work | Office locations, map, remote policy |
| **Perks and Benefits** | Employee benefits | Compensation, perks, work-life balance |
| **Tech Department** | Technology focus | Tech stack, engineering culture, innovation |
| **Teams** | Team/department showcase | Org structure, career paths, team descriptions |
| **About Us** | Company overview | History, business lines, key facts |
| **DEI** | Diversity, Equity, Inclusion | DEI initiatives, commitments, programs |
| **Students** | Early career programs | Internships, apprenticeships, graduate programs |
| **Subsidiaries** | Group entities/brands | Entity descriptions, brand portfolio |
| **CSR** | Corporate Social Responsibility | Environmental, social commitments |

---

## 4. Analysis Output Structure

### 4.1: Organization Overview Section

```markdown
## Organization Overview
- **Name**: [Organization Name]
- **Reference**: `[reference]`
- **Total Pages**: [count]
- **Custom Pages**: [count] ([percentage]%)
- **Standard Pages**: [count] (list slugs)
```

### 4.2: Architecture Note (if shared blocks)

```markdown
## ⚠️ Important Architecture Note

**[Organization] uses a shared-block CMS architecture**: All [X] pages share 
the exact same [Y] content blocks (identical block IDs). Content differentiation 
happens via frontend routing, not unique content per page.
```

### 4.3: Template Mapping Tables

For each template category:

```markdown
### [Category] Template ([count] pages) ✅

| Slug | Purpose | Template Fit |
|------|---------|--------------|
| `/slug-1` | Description | **Template Name** |
| `/slug-2` | Description | **Template Name** |

**Migration recommendation**: [Consolidation strategy]
```

### 4.4: Archive Section

```markdown
## Pages to Archive/Delete

### Draft Pages ([count]) 🗑️

| Slug | Status | Reason |
|------|--------|--------|
| `/slug` | **DRAFT** | Reason for archiving |
```

### 4.5: Summary Table

```markdown
## Summary

| Category | Count | Pages | Template Recommendation |
|----------|-------|-------|------------------------|
| **Template Name** | X | `/page1`, `/page2` | Consolidate to 1 template |
| **Archive** | X | `/draft-page` | Delete |
| **Standard (keep)** | X | `/`, `/jobs` | Keep as-is |
```

### 4.6: Migration Efficiency Metrics

```markdown
## Migration Efficiency

| Metric | Value |
|--------|-------|
| Current custom pages | [X] |
| Proposed template pages | [Y] |
| Pages to archive | [Z] |
| **Page reduction** | **X → Y pages ([percentage]% reduction)** |
```

---

## 5. Special Considerations

### 5.1: Common Consolidation Patterns

| Pattern | Consolidation Opportunity |
|---------|--------------------------|
| Multiple regional/city pages | → Single **Offices** template with map |
| Multiple department/métier pages | → Single **Teams** template with sections |
| Multiple subsidiary/brand pages | → Single **Subsidiaries** template with cards |
| Multiple culture-related pages | → Single **Culture & Story** template |

### 5.2: High-Value Content to Preserve

Flag content that deserves prominent placement:
- DEI initiatives (employer brand value)
- Training centers (CFA, graduate programs)
- Tech stack/innovation content
- Award-winning programs
- Strong CSR commitments

### 5.3: Content Requiring Stakeholder Decision

Some consolidations require business input:
- **Subsidiaries with strong brand identity** (e.g., BETC at Havas) - consolidate or keep separate?
- **Draft pages with potential value** (e.g., incomplete DEI pages)
- **Mystery pages** with unclear purpose

---

## 6. Analysis Checklist

Before finalizing analysis:

- [ ] Extracted organization name, reference, page count
- [ ] Identified architecture type (unique vs shared blocks)
- [ ] Classified all pages by slug semantics
- [ ] Mapped pages to target templates
- [ ] Identified standard pages (keep as-is)
- [ ] Identified draft/deprecated pages (archive)
- [ ] Calculated page reduction percentage
- [ ] Noted special considerations (decisions needed, high-value content)
- [ ] Created recommended template structure

---

## 7. Output File

Save analysis to: `tmp/analysis/<org_reference>_<org_name>_analysis.md`

Example: `tmp/analysis/k2xbLe_sopra_steria_analysis.md`

---

## 8. Common Findings Across Organizations

Based on analyses performed:

| Finding | Frequency | Notes |
|---------|-----------|-------|
| Shared-block architecture | Very common | All pages share identical blocks |
| Department/métier pages | Very common | 8-12 pages typically |
| Regional/office pages | Common | 5-15 location pages |
| Draft pages not cleaned up | Common | 10-30% of pages |
| `_old` suffix pages | Occasional | Deprecated but not deleted |
| Strong Students content | Common | CFA, alternance, stages |
| DEI content | Growing | Often in draft state |

### Typical Page Reduction

| Organization Size | Before | After | Reduction |
|-------------------|--------|-------|-----------|
| Small (15-20 pages) | 15 | 4-5 | 70-75% |
| Medium (25-30 pages) | 25 | 6-8 | 70-75% |
| Large (30+ pages) | 35 | 7-10 | 70-80% |

---

## 9. Tools Used

- **jq**: JSON processing for data extraction
- **page-migration CLI**: Ruby tool for exporting organization data
- **PageClassifier**: Ruby class for identifying standard vs custom pages

---

## Appendix: SQL Query Reference

The organization data is extracted using a SQL query that joins:
- `organizations` - Organization details
- `website_organizations` - Website configuration
- `cms_pages` - Page structure
- `cms_blocks` - Content blocks
- `cms_contents` - Block content items

Query available in: `lib/page_migration/queries/organization_sql.rb`
