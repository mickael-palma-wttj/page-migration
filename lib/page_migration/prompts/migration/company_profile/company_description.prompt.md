{
  "role": "company_researcher",
  "task": "Generate structured company description data",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "company_description",
      "data": {
        "title": "About us",
        "content": "string (merged: tagline 10-20 words + overview 3 paragraphs + quickFacts 2-3 facts + keyProducts 2-3 products + targetMarket 1 sentence) - MUST BE EXACTLY 2000-2400 CHARACTERS",
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "website|article|press-release|company-page|blog-post|interview|financial-report"
          }
        ]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences",
      "NO explanatory text outside JSON",
      "NO comments in JSON",
      "Content field MUST be between 2000-2400 characters (verify count before submitting)"
    ]
  },
  "content": "TAGLINE: 10-20 words, specific and compelling, convey what company does.\nOVERVIEW: 3 paragraphs (3-5 sentences each): core business/value, problem/differentiation, mission/position. Substantive, no platitudes.\nQUICK FACTS: 2-3 facts (founded, headquarters, industry, size, type, funding, revenue, valuation) woven naturally into content as flowing paragraph.\nKEY PRODUCTS: 2-3 flagship products with 1 sentence descriptions, customer benefits, integrated as flowing paragraph.\nTARGET MARKET: 1 sentence covering segments, company sizes, industries, geographies, use cases, integrated as flowing paragraph.\nCHARACTER COUNT: Content field MUST be 2000-2400 characters. Count carefully before submitting. If too short, add more specific details about products, market position, or company achievements. If too long, trim less essential details while keeping core facts.\nSOURCES: 3-10 citations (minimum 1 primary, 1 third-party, prefer last 12 months).\nTONE: Match company's authentic voice—research materials, identify style, apply consistently.\nQUALITY: Use concrete facts, current research, official names, quantifiable metrics, unique differentiators. Avoid vague corporate language, outdated info, unverifiable claims.",
  "example": {
    "type": "company_description",
    "data": {
      "title": "About us",
      "content": "Stripe builds economic infrastructure for the internet, enabling businesses of all sizes to accept payments and manage their finances online.\n\nStripe is a financial technology company that provides payment processing software and APIs for e-commerce websites and mobile applications. Founded in 2010, Stripe has grown to serve millions of businesses worldwide, from startups to Fortune 500 companies, processing hundreds of billions of dollars in transactions annually. The company is headquartered in San Francisco, CA, and has expanded to over 8,000 employees with a valuation of $50B as of 2023 and annual revenue exceeding $14B.\n\nWhat sets Stripe apart is its developer-first approach. Rather than requiring businesses to navigate complex banking relationships and compliance requirements, Stripe provides simple APIs that developers can integrate in hours, not months. The platform handles the complexity of global payments, including multiple currencies, payment methods, fraud prevention, and regulatory compliance. Core offerings include Stripe Payments for payment processing, Stripe Billing for subscription management, Stripe Connect for marketplace infrastructure, and Stripe Treasury for embedded financial services—each designed to simplify complex payment workflows.\n\nStripe's mission is to increase the GDP of the internet by making it easier for businesses to start, run, and scale online. The company primarily serves online businesses ranging from startups to Fortune 500 companies across e-commerce, SaaS, marketplaces, and platforms spanning all industries. They're particularly strong with developer-focused companies and businesses with complex payment needs globally.",
      "sources": [
        {
          "title": "Stripe About Page",
          "url": "https://stripe.com/about",
          "date": "2024-03-15",
          "type": "company-page"
        },
        {
          "title": "TechCrunch: Stripe reaches $50B valuation",
          "url": "https://techcrunch.com/2023/03/14/stripe-valuation-50b",
          "date": "2023-03-14",
          "type": "article"
        },
        {
          "title": "Stripe Newsroom: Q4 2023 Metrics",
          "url": "https://stripe.com/newsroom/news/q4-2023",
          "date": "2024-01-15",
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
  "final_instruction": "Return ONLY the JSON structure following the exact format shown in the example. No markdown, no explanations, no code blocks—pure JSON only. CRITICAL: Verify the content field is between 2000-2400 characters before submitting. If outside this range, adjust by adding specific details (if too short) or trimming less critical information (if too long)."
}
