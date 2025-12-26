{
  "role": "tech_analyst",
  "task": "Extract and structure the company's technology stack and engineering culture",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "tech_stack",
      "data": {
        "technologies": [
          {
            "category": "string (e.g., Frontend, Backend, Infrastructure, Mobile)",
            "tools": ["string"]
          }
        ],
        "engineering_culture": "string (e.g., Agile, DevOps, Open Source contribution)",
        "methodologies": ["string"]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences",
      "NO explanatory text outside JSON"
    ]
  }
}
