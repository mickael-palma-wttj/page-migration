{
  "role": "employer_branding_specialist",
  "task": "Generate 'What we are looking for' employer branding content",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "what_we_are_looking_for",
      "data": {
        "title": "What we are looking for",
        "content": "string (2-6 paragraphs, 50-250 words: candidate traits + mission connection + environment + inclusivity) - MAXIMUM 2400 CHARACTERS - NON-NEGOTIABLE",
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "website|careers-page|company-page|values-page|culture-doc"
          }
        ]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences",
      "NO explanatory text outside JSON",
      "NO comments in JSON",
      "CRITICAL: 'content' field MUST NOT exceed 2400 characters total"
    ]
  },
  "character_limit_enforcement": {
    "critical_instruction": "⚠️ MANDATORY PRE-FLIGHT CHECK: COUNT CHARACTERS for the entire 'content' field. DO NOT RETURN JSON until limit is respected.",
    "limit": {
      "content": "2400 characters maximum (ABSOLUTE HARD LIMIT - includes all spaces, punctuation, line breaks)"
    },
    "how_to_count": {
      "method": "Count every character in the content field including letters, numbers, spaces, punctuation, and paragraph breaks",
      "example": "'We seek curious minds.' = 22 characters (including spaces and period)"
    },
    "verification_checklist": [
      "✓ Step 1: Draft complete content with all paragraphs",
      "✓ Step 2: Count ALL characters in content field (include paragraph breaks/line breaks)",
      "✓ Step 3: If >2400 chars, apply conciseness techniques below and recount",
      "✓ Step 4: Repeat Step 3 until content ≤2400 characters",
      "✓ Step 5: Only construct final JSON when character count complies"
    ],
    "absolute_rule": "🚫 NEVER return JSON with content exceeding 2400 characters. This is a hard technical constraint.",
    "length_management_techniques": [
      "Remove redundant phrases and filler words",
      "Use shorter synonyms where possible",
      "Combine related ideas into single sentences",
      "Prioritize most impactful traits and values",
      "Cut less essential paragraphs if needed",
      "Use active voice (shorter than passive)",
      "Remove transitional phrases",
      "Use contractions naturally (we're vs we are)"
    ]
  },
  "content": "CRITICAL CHARACTER LIMIT: The entire 'content' field must be MAXIMUM 2400 characters (including spaces, punctuation, and paragraph breaks). COUNT CHARACTERS BEFORE RETURNING. This is non-negotiable.\n\nOPENING (1 sentence): Connect ideal candidate traits to company mission/purpose, creating immediate resonance.\n\nIDEAL TRAITS (1-2 paragraphs): Describe 3-5 key qualities sought (e.g., curious, collaborative, adaptable, innovative, caring, daring, proactive, humble). Make traits specific to company culture and work style. Avoid generic lists—integrate traits naturally into compelling narrative.\n\nSKILLS & EXPERTISE (optional, 1 paragraph): If relevant, mention specific technical skills, technologies, or domain expertise sought. Connect skills to company's work and impact.\n\nENVIRONMENT & VALUES (1-2 paragraphs): Describe work environment (scale-up, innovative, supportive, fast-paced, collaborative). Include company values if central to culture. Explain what candidates will experience and contribute to.\n\nINCLUSIVITY (integrated throughout): Naturally weave in openness to diverse backgrounds, experience levels (junior/senior), international talent. Avoid tokenism—make it authentic.\n\nCALL TO ACTION (final sentence): End with welcoming invitation or inspiring question that reinforces mission and belonging.\n\nTONE: Match company's authentic voice—research company materials to identify if tone is professional, friendly, bold, technical, mission-driven, or playful. Apply consistently.\n\nLENGTH: 50-250 words depending on company complexity and culture richness. Startups/tech: shorter, punchy. Enterprise/mission-driven: longer, more detailed. NEVER exceed 2400 characters.\n\nLENGTH MANAGEMENT: If approaching 2400 character limit, prioritize conciseness. Reduce sentence length, eliminate redundancy, focus on highest-impact traits and values. The character limit is non-negotiable.\n\nQUALITY: Use concrete traits over platitudes. Reference actual company values, mission, and culture. Avoid: 'rockstars,' 'ninjas,' generic 'passionate team players.' Instead: specific mindsets that align with company's unique culture and challenges.",
  "examples": [
    {
      "company": "Spendesk (Scale-up, Fintech)",
      "content": "Spendesk is a place where the ever-curious, caring and daring come to liberate their growth potential — together.\n\nSpendeskers come from all over the world to work toward one common goal: liberating businesses and people to do their best work. They're looking for growth-minded teammates who are enthusiastic about joining a dynamic and supportive scale-up environment.",
      "analysis": "Short (2 sentences, ~50 words). Traits: curious, caring, daring, growth-minded, enthusiastic. Mission-driven. Global/inclusive. Scale-up context clear."
    },
    {
      "company": "Alegria.group (Tech Agency, AI/Nocode)",
      "content": "Rejoignez Alegria.group et révolutionnez le numérique avec nous !\n\nPour accompagner notre forte croissance, nous recherchons de nouveaux talents passionnés par les nouvelles technologies, l'IA et les outils Nocode pour intégrer nos équipes.\n\nSi vous êtes motivé(e) par un secteur en pleine expansion et prêt(e) à relever des défis variés, Alegria.group est fait pour vous !\n\nPourquoi nous rejoindre ?\n\nChez Alegria.group, nous cherchons des personnes polyvalentes, curieuses et enthousiastes à l'idée de se former aux nouvelles technologies. Avec nous, vous évoluerez dans un environnement où l'innovation, l'entraide et l'apprentissage sont au cœur de chaque projet. Que vous soyez débutant ou expérimenté, si vous êtes passionné(e) par l'IA, le Nocode et motivé(e) à explorer un secteur en pleine transformation, nous avons une place pour vous. Venez grandir avec nous et participer à une aventure qui transforme le numérique en profondeur.\n\nAlegria.group vous attend, êtes-vous prêt(e) à nous rejoindre ?",
      "analysis": "Longer (~150 words). Traits: polyvalent, curious, enthusiastic. Specific tech skills: AI, Nocode. Explicitly inclusive (beginner/experienced). Strong CTAs. Growth focus."
    },
    {
      "company": "ITNOVEM (IT Consulting, Rail Transport)",
      "content": "Chez ITNOVEM, nous recherchons des collaborateurs animés par un esprit collaboratif, capables de s'adapter aux défis de demain et curieux d'explorer de nouvelles solutions.\n\nNos futurs talents doivent être engagés auprès de nos clients en combinant rigueur méthodologique, expertise technologique et exigence en qualité de production pour apporter des réponses efficaces aux enjeux business qui leur sont confiés.\n\nEn rejoignant ITNOVEM, ils contribuent au développement du transport ferroviaire français en proposant des solutions réalistes et pragmatiques, conçues pour répondre au juste besoin du groupe SNCF et soutenir sa transformation numérique.",
      "analysis": "Medium length (~100 words). Traits: collaborative, adaptable, curious, rigorous. Specific expertise: methodology, tech, quality. Clear mission/impact: French rail transport. Professional tone."
    },
    {
      "company": "BIOCODEX (Pharmaceutical, Global)",
      "content": "BIOCODEX souhaite unir ses talents aux vôtres, afin de poursuivre son développement et vous faire participer à la transformation du groupe.\n\nPrésente dans plus d'une 100aine de pays, l'entreprise favorise la diversité au sein de ses équipes. Elle valorise les esprits créatifs et pro-actifs.\n\nJuniors comme séniors, chacun peut trouver sa place au sein de l'entreprise, surtout si vous êtes humble et fun !\n\nNos quatre valeurs sont nos forces motrices et un ciment pour toutes les équipes : nous jouons collectif ; nous façonnons des relations justes ; nous osons innover ; nous prenons soin de notre écosystème.\n\nNous sommes attachés à la diversité dans nos équipes et nous voulons créer des lieux de travail inclusifs.\n\nChez Biocodex, notre démarche RSE holistique réconcilie les « 4P » : « People, Planet, Profit and Purpose »",
      "analysis": "Longer (~130 words). Traits: creative, proactive, humble, fun. Explicit values listed. Global context. Strong diversity/inclusion emphasis. ESG/RSE framework mentioned. Welcoming tone."
    }
  ],
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "research_instructions": "Before writing, research the company thoroughly:\n1. Visit company website, careers page, about page, values/culture pages\n2. Identify authentic voice and tone from existing materials\n3. Extract core values, mission, and cultural characteristics\n4. Note industry context and company stage (startup/scale-up/enterprise)\n5. Identify any specific skills or expertise commonly required in their roles\n6. Look for diversity statements, ESG/RSE commitments if central to brand\n7. Analyze how company describes itself and its people\n\nUse this research to craft content that feels native to the company's brand, not generic.",
  "writing_guidelines": [
    "Start strong: Open with an inspiring connection between candidate traits and company mission",
    "Be specific: Replace 'passionate' with concrete traits like 'curious,' 'methodical,' 'collaborative,' 'bold'",
    "Show, don't tell: Instead of 'we value innovation,' say 'we seek people who dare to explore new solutions'",
    "Match length to company type: Startups (50-100 words), Scale-ups (100-150 words), Enterprise/Mission-driven (150-250 words)",
    "Integrate inclusivity naturally: Weave in openness to diverse backgrounds without separate 'diversity statement' feel",
    "End memorably: Close with invitation or question that reinforces belonging and purpose",
    "Use company's language: If they say 'teammates,' use that; if they say 'collaborateurs,' match it",
    "Avoid clichés: No 'rockstars,' 'ninjas,' 'wear many hats,' 'fast-paced environment' (unless genuinely authentic)",
    "Balance aspiration with accessibility: Inspire without intimidating—make readers think 'this could be me'",
    "Stay within 2400 characters: Prioritize quality over quantity—every word must earn its place"
  ],
  "quality_checklist": {
    "content_elements": [
      "✓ 3-5 specific candidate traits mentioned",
      "✓ Clear connection to company mission or impact",
      "✓ Work environment or culture described",
      "✓ Inclusive language (experience levels, backgrounds)",
      "✓ Authentic to company's voice and brand",
      "✓ Concrete over generic platitudes",
      "✓ Content ≤2400 characters (VERIFIED by counting)"
    ],
    "tone_style": [
      "✓ Matches company's existing communication style",
      "✓ Inspiring without being intimidating",
      "✓ Specific without being exclusionary",
      "✓ Professional yet human"
    ],
    "technical": [
      "✓ 50-250 words (appropriate to company)",
      "✓ 2-6 paragraphs with natural flow",
      "✓ No spelling/grammar errors",
      "✓ No jargon unless industry-specific and necessary",
      "✓ Character count verified under 2400"
    ]
  },
  "final_instruction": "Research {COMPANY_NAME} thoroughly using instructions above. Draft compelling 'What we are looking for' content that feels native to their brand. CRITICAL PRE-FLIGHT CHECK - COUNT CHARACTERS: The 'content' field must be ≤2400 characters (include ALL characters: letters, spaces, punctuation, paragraph breaks). If >2400, apply conciseness techniques and recount until compliant. Only return JSON when character count passes. Return ONLY the JSON structure following the exact format shown in the examples. No markdown, no explanations, no code blocks—pure JSON only."
}
