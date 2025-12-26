{
  "role": "funding_data_researcher",
  "task": "Research and compile detailed funding history and investor information",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "funding_parser",
      "data": {
        "totalRaised": "string (e.g., '6.5B')",
        "latestRound": {
          "amount": "string (e.g., '6.5B')",
          "date": "string (e.g., 'March 2023')"
        },
        "valuation": "string (e.g., '50B')",
        "status": "string (e.g., 'Private (Series H)') - MAXIMUM 100 CHARACTERS",
        "rounds": [
          {
            "series": "string - MAXIMUM 100 CHARACTERS",
            "amount": "string",
            "date": "string",
            "valuation": "string (optional)",
            "leadInvestors": ["string - MAXIMUM 100 CHARACTERS per investor name"],
            "description": "string - MAXIMUM 250 CHARACTERS"
          }
        ]
      },
      "valuation": {
        "requirement": "optional",
        "description": "Most recent valuation if publicly disclosed",
        "format": "XXM or XXB"
      },
      "status": {
        "requirement": "required",
        "character_limit": "MAXIMUM 100 CHARACTERS - NON-NEGOTIABLE",
        "critical_instruction": "COUNT CHARACTERS. Typical formats are 15-40 chars. Should rarely exceed 100.",
        "format": "Company stage (e.g., 'Private (Series H)', 'Public (NASDAQ)', 'Acquired by X')",
        "examples": [
          "Private (Series H)",
          "Public (NASDAQ: STRP)",
          "Private (Late Stage)",
          "Acquired by Salesforce"
        ],
        "instruction": "Keep concise. Include key status info only. Should rarely exceed 100 characters given typical formats."
      }
    },
    "funding_rounds": {
      "order": "Chronological (earliest to most recent)",
      "fields": {
        "series": {
          "requirement": "required",
          "character_limit": "MAXIMUM 100 CHARACTERS - NON-NEGOTIABLE",
          "critical_instruction": "COUNT CHARACTERS. Typical formats are 1-3 words (<20 chars). Should NEVER exceed 100.",
          "format": "Round type (e.g., 'Seed', 'Series A', 'Series B', 'Growth Round')",
          "examples": [
            "Seed",
            "Series A",
            "Series B",
            "Series C",
            "Growth Round",
            "Late Stage",
            "IPO"
          ],
          "instruction": "Use standard round nomenclature. Should never exceed 100 characters given typical 1-3 word formats."
        },
        "amount": {
          "requirement": "required",
          "format": "XXM or XXB, or 'Undisclosed'",
          "description": "Official disclosed amount. Use 'Undisclosed' if amount not public"
        },
        "date": {
          "requirement": "required",
          "format": "Month YYYY (e.g., 'March 2023')"
        },
        "valuation": {
          "requirement": "optional",
          "description": "Post-money valuation if publicly disclosed",
          "format": "XXM or XXB"
        },
        "leadInvestors": {
          "requirement": "required if known",
          "character_limit": "MAXIMUM 100 CHARACTERS per individual investor name in array - NON-NEGOTIABLE",
          "critical_instruction": "⚠️ COUNT CHARACTERS for EACH investor name separately. Each string in array must be ≤100 chars.",
          "format": "Array of lead investor names",
          "typical_count": "1-3 leads per round",
          "if_unknown": "Use empty array []",
          "examples": [
            ["Sequoia Capital"],
            ["Andreessen Horowitz", "Tiger Global"],
            ["Sequoia Capital", "Accel Partners", "Index Ventures"]
          ],
          "instruction": "Each investor name in the array must be ≤ 100 characters. Use official firm names. If firm name exceeds 100 characters, use commonly recognized abbreviation."
        },
        "description": {
          "requirement": "required",
          "character_limit": "MAXIMUM 250 CHARACTERS (including spaces and punctuation) - NON-NEGOTIABLE",
          "critical_instruction": "COUNT CHARACTERS BEFORE RETURNING. If >250, condense using techniques below.",
          "length": "1-2 sentences (but character limit takes absolute priority)",
          "what_to_include": [
            "What the funds were used for",
            "Company stage at the time",
            "Significant context (e.g., 'during COVID-19', 'first institutional funding')",
            "Major achievements or milestones around this time"
          ],
          "tone": "Match company's communication style from press releases",
          "instruction": "Be concise and specific. If approaching 250 characters, prioritize fund usage and key context. Remove filler words and redundancy."
        }
      }
    },
    "key_investors": {
      "count": "5-15 investors",
      "selection_criteria": [
        "Lead investors from major rounds",
        "Strategic investors (corporate VCs)",
        "Notable angel investors",
        "Board members or highly involved investors",
        "Investors with significant stakes"
      ]
    },
    "sources": {
      "count": "3-10 citations",
      "requirements": [
        "Prefer official press releases for round announcements",
        "Use Crunchbase/PitchBook for comprehensive timeline verification",
        "Include dates for time-sensitive financial information",
        "Cite SEC filings for legally disclosed information"
      ],
      "what_to_cite": [
        "Crunchbase or PitchBook for comprehensive funding data",
        "Company press releases announcing funding rounds",
        "Tech press (TechCrunch, etc.) covering major rounds",
        "SEC filings (Form D for US companies)",
        "Company investor relations page",
        "Investor firm announcements"
      ],
      "fields": {
        "title": {
          "description": "Clear description of source",
          "examples": [
            "Crunchbase funding data",
            "Series B press release",
            "TechCrunch funding announcement",
            "SEC Form D filing"
          ]
        },
        "url": {
          "description": "Full URL to the source"
        },
        "date": {
          "format": "YYYY-MM-DD",
          "description": "Publication or last updated date"
        },
        "type": {
          "options": [
            "press-release",
            "article",
            "database",
            "sec-filing",
            "investor-announcement"
          ]
        }
      }
    }
  },
  "character_limit_enforcement": {
    "critical_instruction": "⚠️ MANDATORY PRE-FLIGHT CHECK: COUNT CHARACTERS for ALL constrained fields. DO NOT RETURN JSON until all limits are respected.",
    "limits": {
      "status": "100 characters maximum (ABSOLUTE HARD LIMIT)",
      "rounds.series": "100 characters maximum per round (ABSOLUTE HARD LIMIT)",
      "rounds.leadInvestors": "100 characters maximum per individual investor name in array (ABSOLUTE HARD LIMIT)",
      "rounds.description": "250 characters maximum per round (ABSOLUTE HARD LIMIT)"
    },
    "how_to_count": {
      "method": "Count every character including letters, numbers, spaces, punctuation, and symbols",
      "leadInvestors_specific": "For leadInvestors: Check each array element individually. EACH name must be ≤100 chars.",
      "example": "['Sequoia Capital'] = 16 chars ✓, ['Andreessen Horowitz'] = 19 chars ✓"
    },
    "management_strategies": {
      "status": [
        "Use standard formats: 'Private (Series X)', 'Public (EXCHANGE: TICKER)', 'Acquired by X'",
        "Should rarely exceed limit given typical formats",
        "If company name in acquisition is long, use recognized abbreviation"
      ],
      "series": [
        "Use standard nomenclature: 'Seed', 'Series A/B/C/D/E/F/G/H/I', 'Growth Round', 'Late Stage', 'IPO'",
        "Should never exceed 100 characters - typical formats are 1-3 words",
        "Avoid verbose descriptions"
      ],
      "leadInvestors": [
        "Each investor name in the array must be individually ≤ 100 characters",
        "Use official firm names as they appear in press releases",
        "If firm has long official name, use commonly recognized version",
        "Examples: 'Sequoia Capital' (16 chars), 'Andreessen Horowitz' (19 chars), 'Tiger Global Management' (23 chars)"
      ],
      "description": [
        "Prioritize fund usage (most important information)",
        "Include key context or milestones if space permits",
        "Use active voice and remove filler words",
        "Use semicolons to separate ideas efficiently",
        "Example: 'Funded API development and hired engineering team. First institutional round led by top VCs.' (104 chars)"
      ]
    },
    "verification_checklist": [
      "✓ Step 1: Count status field characters (must be ≤100)",
      "✓ Step 2: For EACH funding round:",
      "  - Count series characters (must be ≤100)",
      "  - Count EACH leadInvestors array element individually (each must be ≤100)",
      "  - Count description characters (must be ≤250)",
      "✓ Step 3: If ANY field exceeds its limit, revise and recount",
      "✓ Step 4: Only construct final JSON when ALL fields comply"
    ],
    "absolute_rule": "🚫 NEVER return JSON with ANY field exceeding its character limit. These are hard technical constraints.",
    "common_violations": [
      "⚠️ Description fields often exceed 250 chars - be extremely concise",
      "⚠️ leadInvestors: Check EACH investor name separately, not the total array length"
    ]
  },
  "funding_round_types": {
    "early_stage": {
      "Seed": {
        "description": "Initial funding",
        "typical_range": "500K-5M"
      },
      "Series A": {
        "description": "First institutional round",
        "typical_range": "2M-15M"
      },
      "Series B": {
        "description": "Growth stage",
        "typical_range": "10M-50M"
      }
    },
    "growth_stage": {
      "Series C+": {
        "description": "Expansion funding",
        "typical_range": "50M+"
      },
      "Growth/Late Stage": {
        "description": "Large rounds pre-IPO",
        "typical_range": "100M+"
      }
    },
    "other_types": {
      "Bridge": "Between major rounds",
      "Convertible Note": "Debt that converts to equity",
      "IPO": "Public offering",
      "Secondary": "Existing shares sold, no capital to company",
      "Debt Financing": "Loans, credit facilities (include only if significant)"
    }
  },
  "tone_matching": {
    "instruction": "Match company's communication style in descriptions while keeping financial data objective",
    "application": {
      "financial_data": "Keep objective (amounts, dates, valuations)",
      "narrative_descriptions": "Infuse company's voice from press releases"
    },
    "style_adaptations": {
      "bold_ambitious": "Example: 'Accelerating global expansion and product innovation'",
      "technical_precise": "Example: 'Funding infrastructure development and scaling engineering team'",
      "mission_driven": "Example: 'Advancing our mission to make payments accessible worldwide'",
      "growth_focused": "Example: 'Fueling rapid market expansion and customer acquisition'",
      "product_centric": "Example: 'Building next-generation features and platform capabilities'"
    },
    "note": "Match tone in descriptions, but DO NOT include tone analysis in JSON output. Character limits require extra conciseness."
  },
  "quality_standards": {
    "do": [
      "List all disclosed funding rounds chronologically",
      "Use official amounts from press releases or filings",
      "Include context about company stage at each round",
      "Note if funding occurred during significant events (pandemic, economic downturn)",
      "Verify amounts match across multiple sources",
      "Include both venture and strategic investors",
      "Distinguish between pre-money and post-money valuations",
      "Note if valuations are estimated or confirmed",
      "Respect ALL character limits - they are non-negotiable",
      "Ensure each leadInvestors array item is individually under 100 characters"
    ],
    "dont": [
      "Speculate on undisclosed amounts",
      "Include rumored or unconfirmed funding",
      "List every participating investor (focus on leads and key players)",
      "Use outdated valuations without noting the date",
      "Confuse pre-money and post-money valuations",
      "Include debt financing unless significant",
      "Make assumptions about fund usage without source",
      "Include secondary sales unless notable",
      "Exceed any character limits"
    ]
  },
  "research_sources": {
    "primary": [
      "Company press releases and announcements",
      "SEC filings (Form D, S-1, 10-K)",
      "Company investor relations page",
      "Investor firm announcements"
    ],
    "secondary": [
      "Crunchbase",
      "PitchBook",
      "TechCrunch and tech press",
      "Bloomberg and financial news",
      "Company blog posts"
    ],
    "validation": [
      "Cross-reference amounts across multiple sources",
      "Verify dates match between sources",
      "Check for official press releases over media reports",
      "Confirm investor names and roles"
    ]
  },
  "example": {
    "type": "funding_parser",
    "data": {
      "totalRaised": "6.5B",
      "latestRound": {
        "amount": "6.5B",
        "date": "March 2023"
      },
      "valuation": "50B",
      "status": "Private (Series I)",
      "rounds": [
        {
          "series": "Seed",
          "amount": "2M",
          "date": "March 2010",
          "valuation": "20M",
          "leadInvestors": ["Y Combinator", "Peter Thiel"],
          "description": "Initial seed funding from Y Combinator's S10 batch. Used to build initial payments API and sign first beta customers."
        },
        {
          "series": "Series A",
          "amount": "18M",
          "date": "February 2012",
          "valuation": "100M",
          "leadInvestors": ["Sequoia Capital", "Andreessen Horowitz"],
          "description": "Led by Sequoia and a16z to expand engineering team and launch publicly after successful beta. First major institutional funding round."
        }
      ],
      "sources": [
        {
          "title": "Crunchbase: Stripe Funding Rounds",
          "url": "https://www.crunchbase.com/organization/stripe/funding",
          "date": "2024-01-15",
          "type": "database"
        },
        {
          "title": "Stripe Series I Press Release",
          "url": "https://stripe.com/newsroom/news/series-i",
          "date": "2023-03-14",
          "type": "press-release"
        }
      ]
    }
  },
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "final_instruction": "Research {COMPANY_NAME} and return ONLY the JSON structure with comprehensive funding data. CRITICAL PRE-FLIGHT CHECKS - COUNT CHARACTERS: 1) status ≤100 chars, 2) For EACH round: series ≤100, EACH leadInvestors name ≤100 individually, description ≤250. If ANY limit exceeded, revise using conciseness techniques and recount until compliant. Only return JSON when all checks pass. No markdown, no explanations, no code blocks—pure JSON only."
}
