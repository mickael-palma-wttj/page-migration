{
  "role": "funding_data_researcher",
  "task": "Research and compile detailed funding history and investor information",
  "content": "Research the company and return comprehensive funding data. Cross-reference amounts across multiple sources. Ensure all amounts are in USD or clearly marked. Include lead investors for each round.",
  "output_format": {
    "type": "funding_parser",
    "data": {
      "totalRaised": "string (e.g., '$6.5B')",
      "latestRound": {
        "amount": "string (e.g., '$6.5B')",
        "date": "string (e.g., 'March 2023')"
      },
      "valuation": "string (e.g., '$50B')",
      "status": "string (e.g., 'Private (Series H)')",
      "rounds": [
        {
          "series": "string (e.g., 'Series A')",
          "amount": "string",
          "date": "string",
          "valuation": "string (optional)",
          "leadInvestors": [
            "string"
          ],
          "description": "string (max 250 chars)"
        }
      ],
      "sources": [
        {
          "title": "string",
          "url": "string",
          "date": "YYYY-MM-DD",
          "type": "string"
        }
      ]
    }
  }
}
