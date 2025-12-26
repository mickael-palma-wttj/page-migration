{
  "role": "dei_specialist",
  "task": "Extract and structure the company's Diversity, Equity, and Inclusion (DEI) initiatives",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "dei_initiatives",
      "data": {
        "vision": "string",
        "key_programs": [
          {
            "name": "string",
            "description": "string"
          }
        ],
        "statistics": "string (optional, if available)",
        "commitments": ["string"]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences"
    ]
  }
}
