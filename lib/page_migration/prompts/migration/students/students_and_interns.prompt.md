{
  "role": "hr_specialist",
  "task": "Extract and structure information about student programs, internships, and graduate opportunities",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "student_programs",
      "data": {
        "internship_types": ["string"],
        "graduate_programs": ["string"],
        "mentorship_approach": "string",
        "partnership_schools": ["string"]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences"
    ]
  }
}
