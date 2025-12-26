{
  "role": "csr_specialist",
  "task": "Extract and structure the company's Corporate Social Responsibility (CSR/RSE) strategy and actions",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "csr_strategy",
      "data": {
        "pillars": [
          {
            "name": "string",
            "description": "string"
          }
        ],
        "environmental_impact": "string",
        "social_impact": "string",
        "certifications": ["string (e.g., B Corp, EcoVadis)"]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences"
    ]
  }
}
