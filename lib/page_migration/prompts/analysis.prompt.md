---
role: "Migration Architect"
task: "Analyze organization pages and recommend migration strategy to standardized templates"
output_format:
  type: "markdown"
---

# Page Migration Fit Analysis

Analyze the provided organization data and produce a migration recommendation report.

## Your Task

1. **Count pages** by status (published, draft, to_validate)
2. **Classify each page** using slug patterns (see mapping below)
3. **Map to target templates** and identify consolidation opportunities
4. **Calculate page reduction** potential

## Page Classification Rules

### Standard Pages (keep as-is)
- `/` - Home/Profile
- `/jobs` - Job listings
- `/meetings` - Recruitment events
- `/team`, `/team-1` - Team showcase

### Custom Page → Template Mapping

| Slug Pattern | Target Template |
|--------------|-----------------|
| City names (`/paris`, `/lyon`, `/bordeaux`) | Offices and Remote policy |
| `/region-*`, geographic names | Offices and Remote policy |
| `/metiers-*`, `/nos-metiers`, job titles | Teams |
| `/culture`, `/vie-*`, `/ambiance` | Culture & Story |
| `/engagements`, `/csr`, `/rse` | CSR |
| `/diversite`, `/inclusion`, `/dei` | DEI |
| `/alternance`, `/stages`, `/jeunes-talents` | Students |
| `/avantages`, `/benefits`, `/qvct` | Perks and Benefits |
| `/tech`, `/it-*`, `/digital` | Tech Department |
| `/entites`, `/filiales`, brand names | Subsidiaries |
| `/notre-entreprise`, `/about`, `/histoire` | About Us |

### Archive Candidates
- Status = `draft` or `to_validate`
- Slugs ending with `_old`
- Duplicate content pages

## Available Target Templates

| Template | Purpose |
|----------|---------|
| Culture & Story | Company culture, values, history |
| Offices and Remote policy | Office locations, remote work policy |
| Perks and Benefits | Employee benefits, compensation |
| Tech Department | Tech stack, engineering culture |
| Teams | Department showcase, career paths |
| About Us | Company overview, key facts |
| DEI | Diversity, Equity, Inclusion initiatives |
| Students | Internships, apprenticeships, graduate programs |
| Subsidiaries | Group entities, brand portfolio |
| CSR | Environmental and social commitments |

## Consolidation Patterns

- Multiple city/regional pages → Single **Offices** template
- Multiple department/role pages → Single **Teams** template
- Multiple subsidiary pages → Single **Subsidiaries** template

## Required Output Format

```markdown
# Migration Analysis: [Organization Name]

## Overview
- **Reference**: `[ref]`
- **Total Pages**: X
- **Custom Pages**: Y (Z%)
- **Standard Pages**: W

## Template Mapping

### [Template Name] (X pages)
| Slug | Status | Recommendation |
|------|--------|----------------|

**Consolidation**: [strategy]

## Pages to Archive (X pages)
| Slug | Status | Reason |
|------|--------|--------|

## Summary
| Category | Count | Action |
|----------|-------|--------|
| Keep (standard) | X | No change |
| Migrate to templates | Y | Consolidate |
| Archive | Z | Delete |

## Migration Efficiency
- Current pages: X
- After migration: Y
- **Reduction: Z%**

## Decisions Needed
- [List any pages requiring stakeholder input]
```
