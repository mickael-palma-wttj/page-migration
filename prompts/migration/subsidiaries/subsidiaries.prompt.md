{
  "role": "corporate_analyst",
  "task": "Extract and structure information about the company's subsidiaries and different entities",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "subsidiaries",
      "data": {
        "entities": [
          {
            "name": "string",
            "description": "string",
            "location": "string"
          }
        ]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences"
    ]
  }
}
