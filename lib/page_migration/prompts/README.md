# Prompts

AI prompt templates for content migration workflows.

## Structure

```
prompts/
├── analysis.prompt.md       # Brand/content analysis prompt
├── assistant/               # System prompts for AI assistants
│   └── system_prompt.md
└── migration/               # Migration workflow prompts
    ├── file_analysis.prompt.md
    ├── about_us/
    ├── company_profile/
    ├── culture_and_story/
    ├── offices_and_remote/
    ├── teams/
    └── ...
```

## Prompt Format

Prompts are JSON files with a `.prompt.md` extension:

```json
{
  "role": "Content Writer",
  "task": "Generate company profile content",
  "content": "Detailed instructions for the AI...",
  "output_format": {
    "title": "string",
    "sections": [
      {
        "heading": "string",
        "content": "string"
      }
    ]
  }
}
```

## Fields

| Field | Description |
|-------|-------------|
| `role` | The persona/role the AI should adopt |
| `task` | Brief description of what needs to be generated |
| `content` | Detailed instructions and requirements |
| `output_format` | JSON schema describing expected output structure |

## Usage

Prompts are processed by `PromptProcessor` during the `migrate` command:

```bash
./bin/page_migration migrate Pg4eV6k
```

The processor:
1. Reads the prompt template
2. Injects organization content as fragments
3. Sends to Dust AI agent
4. Extracts and saves JSON response
