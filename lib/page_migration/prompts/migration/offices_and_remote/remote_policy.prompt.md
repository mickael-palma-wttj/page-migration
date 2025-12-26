{
  "role": "remote_work_policy_researcher",
  "task": "Research and provide comprehensive information about company remote work policies, flexibility, and distributed work culture",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "remote_policy",
      "data": {
        "models": ["string"],
        "summary": "string (2-3 sentences) - MAXIMUM 250 CHARACTERS",
        "policy_details": "string (1-2 sentences) - MAXIMUM 250 CHARACTERS",
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "company-page|article|press-release|employee-review|blog-post|job-posting|interview"
          }
        ]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences",
      "NO explanatory text outside JSON",
      "NO comments in JSON",
      "CRITICAL: Enforce ALL character limits exactly - summary max 250, policy_details max 250"
    ]
  },
  "content_guidelines": {
    "models": {
      "requirement": "required",
      "format": "array of strings",
      "description": "Select ALL applicable remote work models that the company offers. This MUST be an array. Include multiple models if the company provides different arrangements for different roles or if employees can choose between options.",
      "options": {
        "Office-First": {
          "definition": "Primarily in-office with limited remote options",
          "characteristics": [
            "Default expectation is office presence",
            "Remote work by exception or limited days",
            "Example: In office 5 days/week with 1-2 remote days allowed"
          ]
        },
        "Hybrid-Required": {
          "definition": "Mix of office and remote with set requirements",
          "characteristics": [
            "Set hybrid schedule (e.g., 3 days office, 2 remote)",
            "Specific days may be required",
            "Example: Tuesday, Wednesday, Thursday in office"
          ]
        },
        "Hybrid-Flexible": {
          "definition": "Mix of office and remote, employee choice",
          "characteristics": [
            "Employees choose mix of office/remote",
            "No set schedule",
            "Example: Come to office as needed for your work"
          ]
        },
        "Remote-First": {
          "definition": "Default remote with optional office access",
          "characteristics": [
            "Optimized for distributed work",
            "Offices available but optional",
            "Example: 50%+ employees fully remote"
          ]
        },
        "Fully Remote": {
          "definition": "No physical offices, entirely distributed",
          "characteristics": [
            "No permanent offices",
            "All employees distributed",
            "Example: Entire company is remote with co-working stipends"
          ]
        }
      },
      "selection_examples": [
        "Single model: [\"Hybrid-Required\"]",
        "Multiple models: [\"Hybrid-Flexible\", \"Fully Remote\"]",
        "Company with different options by role: [\"Office-First\", \"Hybrid-Required\", \"Fully Remote\"]"
      ]
    },
    "summary": {
      "requirement": "required",
      "character_limit": "MAXIMUM 250 CHARACTERS (including spaces and punctuation)",
      "length": "2-3 sentences (extremely concise given character limit)",
      "purpose": "Capture essence of remote work philosophy",
      "what_to_include": [
        "Overall stance on remote work",
        "Flexibility employees have",
        "Reasoning behind their approach (if space permits)",
        "Long-term commitment or temporary (if relevant)"
      ],
      "instruction": "CRITICAL: Must be very concise. 250 characters = ~35-40 words max. Prioritize the most important aspects. Remove all filler words. Use direct language. Focus on what employees can actually do.",
      "conciseness_techniques": [
        "Remove articles (a, an, the) where acceptable",
        "Use active voice only",
        "Eliminate transitional phrases",
        "Use abbreviations: '2 days/week' not 'two days per week'",
        "Combine related ideas with semicolons",
        "Start with key policy, then add context if space allows",
        "Use '&' instead of 'and' where appropriate"
      ],
      "good_example": "Qonto prioritizes in-person collaboration but offers hybrid flexibility: up to 2 remote days/week plus 12 bonus days/year. Full-remote available by exception for specific roles, balancing team connection with talent access.",
      "character_count_note": "Above example is 242 characters - fits within limit while covering key points"
    },
    "policy_details": {
      "requirement": "required",
      "character_limit": "MAXIMUM 250 CHARACTERS (including spaces and punctuation) - NON-NEGOTIABLE",
      "length": "1-2 sentences (but character limit takes absolute priority)",
      "critical_instruction": "COUNT CHARACTERS BEFORE RETURNING. If >250, you MUST condense. This field is for FACTS ONLY, not philosophy.",
      "what_to_include": [
        "Number of remote days allowed (per week/month/year) - PRIORITY",
        "Geographic restrictions (timezone requirements, country limitations)",
        "Where employees can work from",
        "Percentage of remote workers if known",
        "Office availability and locations (if space)",
        "Any role-specific variations"
      ],
      "instruction": "CRITICAL: Must be extremely concise. 250 characters = ~35-40 words max. Prioritize concrete details over philosophy. Focus on numbers, locations, restrictions. Remove all unnecessary words.",
      "conciseness_techniques": [
        "Lead with most important detail (usually remote days allowed)",
        "Use abbreviations and symbols: '2 days/wk', '+/- 3hrs', '50%+', etc.",
        "Remove 'employees can' - just state the policy",
        "Use commas to separate details efficiently",
        "Skip transitional phrases",
        "Use '&' instead of 'and'",
        "Be precise: '2 days/week' not 'flexible arrangement'"
      ],
      "good_example": "Up to 2 remote days/week + 12 bonus days/year from +/- 3hrs CET. Full-remote by exception for specific roles. Offices in Paris, Berlin, Milan & Barcelona.",
      "character_count_note": "Above example is 153 characters - concise and informative"
    },
    "sources": {
      "count": "2-8 citations",
      "criticality": "REQUIRED - Must include verifiable sources",
      "priority": "Official company sources for policies, employee reviews for actual practices",
      "types": {
        "company-page": "Careers page, remote work policy page, employee handbook sections",
        "article": "News articles, blog posts about company's remote work announcements",
        "press-release": "Official announcements about remote work changes",
        "employee-review": "Glassdoor, Blind, or other employee review sites (for validation)",
        "blog-post": "Company engineering/culture blog posts about remote work",
        "job-posting": "Job listings that specify remote work arrangements",
        "interview": "Leadership interviews discussing remote work philosophy"
      },
      "quality_guidelines": [
        "Prioritize official company sources for formal policies",
        "Use employee reviews to validate actual practice vs. stated policy",
        "Include recent job postings to show current remote work options",
        "Link to specific blog posts about remote work changes or philosophy",
        "If policy differs by team/role, cite sources for each variation",
        "Date sources appropriately (policies from last 1-2 years most relevant)"
      ],
      "fields": {
        "title": {
          "description": "Clear, descriptive title of the source",
          "examples": [
            "Remote Work at Stripe - Careers Page",
            "Stripe Employee Reviews - Remote Work",
            "How Stripe Built a Hybrid-First Culture",
            "Stripe's Remote Work Equipment Policy"
          ]
        },
        "url": {
          "description": "Direct link to the source (must be accessible)"
        },
        "date": {
          "format": "YYYY-MM-DD",
          "description": "Publication or last update date"
        },
        "type": {
          "options": [
            "company-page",
            "article",
            "press-release",
            "employee-review",
            "blog-post",
            "job-posting",
            "interview"
          ]
        }
      }
    }
  },
  "character_limit_enforcement": {
    "critical_instruction": "⚠️ MANDATORY PRE-FLIGHT CHECK: COUNT CHARACTERS for both summary and policy_details. If EITHER exceeds 250 characters, you MUST revise and recount. DO NOT RETURN JSON until both fields are ≤250 characters.",
    "limits": {
      "summary": "250 characters maximum (ABSOLUTE HARD LIMIT)",
      "policy_details": "250 characters maximum (ABSOLUTE HARD LIMIT)"
    },
    "how_to_count": {
      "method": "Count every character including letters, numbers, spaces, punctuation, and symbols",
      "example": "'Hello world!' = 12 characters (including space and exclamation mark)"
    },
    "context": {
      "note": "250 characters is approximately 35-40 words. This is very tight - every word must add value.",
      "comparison": "A typical tweet is 280 characters. You have less space than a tweet for each field."
    },
    "management_strategies": {
      "summary": [
        "250 chars = ~35-40 words maximum",
        "Prioritization order: 1) Core policy (hybrid/remote/office), 2) Specific numbers, 3) Key reasoning",
        "Start with the most important information",
        "Use short, direct sentences",
        "Eliminate all filler: 'the company', 'employees can', 'it is possible to'",
        "Use abbreviations: 'wk' for week, 'yr' for year, 'hrs' for hours",
        "Use symbols: '&' for 'and', '+' for 'plus', '/' for 'per'",
        "Remove qualifiers if not essential: 'very', 'quite', 'generally'",
        "Combine related points with semicolons or commas",
        "Example transformation:",
        "  BEFORE (338 chars): 'Qonto prioritizes in-person collaboration as essential for building strong teams and delivering results faster. While office presence is the preferred default, the company offers structured flexibility through hybrid work (up to 2 remote days per week) and exceptional full-remote arrangements for roles where it serves both employee needs and business goals.'",
        "  AFTER (242 chars): 'Qonto prioritizes in-person collaboration but offers hybrid flexibility: up to 2 remote days/week plus 12 bonus days/year. Full-remote available by exception for specific roles, balancing team connection with talent access.'"
      ],
      "policy_details": [
        "250 chars = ~35-40 words maximum",
        "Lead with concrete numbers: remote days allowed, geographic restrictions",
        "Be extremely specific and factual",
        "Remove all narrative elements - just state the facts",
        "Use abbreviations aggressively: 'wk', 'yr', 'hrs', etc.",
        "List format with commas when covering multiple aspects",
        "Skip 'employees can' or 'the company allows' - just state policy",
        "Example format: 'X days/week remote, +/- Y hrs timezone, offices in [cities], Z% remote employees'",
        "Example transformation:",
        "  BEFORE (272 chars): 'Employees can work remotely up to 2 days per week, plus 12 bonus remote days per year from within plus or minus 3 hours of Central European Time. Full remote arrangements are available by exception for specific roles. The company has offices in Paris, Berlin, Milan, and Barcelona.'",
        "  AFTER (153 chars): 'Up to 2 remote days/week + 12 bonus days/year from +/- 3hrs CET. Full-remote by exception for specific roles. Offices in Paris, Berlin, Milan & Barcelona.'"
      ]
    },
    "verification_checklist": [
      "✓ Step 1: Draft summary - focus on essential policy info",
      "✓ Step 2: Count characters in summary (include ALL characters: letters, spaces, punctuation)",
      "✓ Step 3: If summary >250 chars, apply conciseness techniques and recount",
      "✓ Step 4: Draft policy_details - focus on concrete numbers and facts",
      "✓ Step 5: Count characters in policy_details (include ALL characters)",
      "✓ Step 6: If policy_details >250 chars, apply conciseness techniques and recount",
      "✓ Step 7: Repeat steps 3 and 6 until BOTH fields are ≤250 characters",
      "✓ Step 8: Only then construct final JSON response"
    ],
    "absolute_rule": "🚫 NEVER return JSON with summary or policy_details exceeding 250 characters. This is a hard technical constraint, not a guideline."
  },
  "tone_matching": {
    "instruction": "Match company's tone when describing remote work policies in the summary and policy_details fields",
    "style_adaptations": {
      "employee_centric": {
        "companies": "GitLab, Buffer",
        "style": "Warm, transparent, detailed language emphasizing trust and flexibility",
        "example": "We trust our team members to work when and where they're most productive"
      },
      "tech_forward": {
        "companies": "Stripe, Shopify",
        "style": "Practical, data-driven language focusing on tools and processes",
        "example": "Our remote infrastructure enables seamless collaboration across time zones"
      },
      "traditional": {
        "companies": "Banks, enterprises",
        "style": "Professional, policy-focused language emphasizing structure and guidelines",
        "example": "Remote work arrangements follow established guidelines and manager approval"
      },
      "startup_culture": {
        "style": "Casual, authentic language reflecting actual practices over formal policies",
        "example": "Work from wherever you're happiest - we care about output, not location"
      }
    },
    "principle": "Match how the company communicates about work culture and benefits. However, with 250 character limits, prioritize clarity and specificity over stylistic flourishes. The extreme brevity required means tone comes through word choice rather than sentence structure."
  },
  "quality_standards": {
    "do": [
      "Be specific about policies (not vague 'we support flexibility')",
      "Include both official policy and actual practice",
      "Note if policies differ by role or team",
      "Mention if policy has changed recently",
      "Include geographic limitations clearly",
      "Explain the 'why' behind policies when space allows (summary only)",
      "Verify information from multiple sources",
      "Include employee perspective from reviews",
      "Note percentage of remote workers if known",
      "Specify budget amounts and timeframes",
      "Return models as an array, even if only one model applies",
      "Respect character limits - extreme conciseness is required",
      "Prioritize concrete details over narrative"
    ],
    "dont": [
      "Copy marketing language about 'flexible culture'",
      "Ignore negative aspects mentioned in reviews",
      "Assume flexibility means no structure",
      "Confuse 'work from anywhere' with 'hire from anywhere'",
      "Oversell remote culture if reviews suggest issues",
      "List every communication tool (focus on primary ones)",
      "Include speculative or unverified policies",
      "Use generic descriptions without specifics",
      "Ignore timezone or location restrictions",
      "Return models as a string or pipe-separated value - it must always be an array",
      "Exceed 250 character limits for summary or policy_details",
      "Use verbose language when concise alternatives exist"
    ]
  },
  "research_process": {
    "steps": [
      "1. Check company careers page for official remote work policy",
      "2. Review job postings to see remote work options offered",
      "3. Search for company blog posts about remote work philosophy",
      "4. Check employee reviews (Glassdoor, Blind) for actual practices",
      "5. Look for press releases about remote work policy changes",
      "6. Search for leadership interviews discussing remote work",
      "7. Verify equipment budgets and support from multiple sources",
      "8. Identify tools used from job descriptions or tech blog posts",
      "9. Look for information about in-person gatherings frequency",
      "10. Cross-reference all information across sources"
    ],
    "verification": [
      "Confirm policy is current (within last 1-2 years)",
      "Check if employee reviews align with official policy",
      "Verify geographic restrictions and legal entity locations",
      "Confirm equipment budgets and what's provided",
      "Validate meeting culture and async practices",
      "Check if policy differs by team, role, or seniority",
      "Verify in-person gathering frequency and coverage"
    ]
  },
  "edge_cases": {
    "no_information_found": "Return JSON with models: [\"Office-First\"], explain in summary that no remote work policy was found, and include sources showing this (e.g., job postings requiring office presence)",
    "policy_recently_changed": "Note this in summary and include sources from both before and after the change",
    "policy_differs_by_role": "Include all applicable models in the array and explain variations in policy_details",
    "conflicting_information": "Prioritize official company sources but note discrepancies in policy_details if space allows"
  },
  "example": {
    "type": "remote_policy",
    "data": {
      "models": ["Hybrid-Flexible", "Fully Remote"],
      "summary": "Qonto prioritizes in-person collaboration but offers hybrid flexibility: up to 2 remote days/week plus 12 bonus days/year. Full-remote available by exception for specific roles, balancing team connection with talent access.",
      "policy_details": "Up to 2 remote days/week + 12 bonus days/year from +/- 3hrs CET. Full-remote by exception for specific roles. Offices in Paris, Berlin, Milan & Barcelona.",
      "sources": [
        {
          "title": "Remote Work at Qonto - Careers Page",
          "url": "https://qonto.com/en/careers",
          "date": "2024-01-15",
          "type": "company-page"
        },
        {
          "title": "Embracing hybrid work at Qonto: our vision for balance and success",
          "url": "https://medium.com/qonto-way/embracing-hybrid-work-at-qonto-our-vision-for-balance-and-success-865b346633f2",
          "date": "2024-10-15",
          "type": "blog-post"
        }
      ]
    },
    "note_on_example": "Summary: 242 characters ✓. Policy_details: 153 characters ✓. Both under 250 char limit."
  },
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "final_instruction": "Research {COMPANY_NAME} using the process above and return ONLY the JSON structure with comprehensive, verified remote work policy information. CRITICAL PRE-FLIGHT CHECKS: 1) The 'models' field MUST be an array of strings, even if there's only one model (e.g., [\"Hybrid-Required\"] NOT \"Hybrid-Required\"). 2) COUNT CHARACTERS: summary must be ≤250 characters. 3) COUNT CHARACTERS: policy_details must be ≤250 characters. If either exceeds 250, revise using conciseness techniques from above and recount until compliant. Only return JSON when all checks pass. No markdown code blocks, no explanations, no code fences—pure JSON only."
}
