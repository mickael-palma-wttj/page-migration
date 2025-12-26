{
  "role": "org_designer",
  "task": "Extract and structure the company's team organization and department breakdown",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "team_structure",
      "data": {
        "departments": [
          {
            "name": "string",
            "description": "string",
            "key_roles": ["string"]
          }
        ],
        "collaboration_style": "string"
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences"
    ]
  }
}
