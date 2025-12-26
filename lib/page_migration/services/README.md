# Services

Business logic services for processing and transforming data.

## Components

### PromptProcessor (`prompt_processor.rb`)

Processes prompt template files and generates AI responses via Dust.

**Usage:**

```ruby
processor = PageMigration::Services::PromptProcessor.new(
  client,
  {},
  runner,
  language: 'fr'
)

result = processor.process(
  'lib/page_migration/prompts/migration/example.prompt.md',
  content_summary,
  'tmp/output',
  additional_instructions: "Extra guidelines..."
)
```

**Features:**

- Parses JSON prompt template files
- Chunks large content into multiple fragments (max 500KB each)
- Sends content as fragments to avoid API limits
- Extracts JSON from AI responses
- Saves results to output directory

**Prompt Template Format:**

```json
{
  "role": "Content Writer",
  "task": "Generate marketing copy",
  "content": "Detailed instructions...",
  "output_format": {
    "title": "string",
    "body": "string"
  }
}
```

**Content Chunking:**

When content exceeds 500KB, it's automatically split into multiple content fragments:
- `Organization Data (Part 1/N)`
- `Organization Data (Part 2/N)`
- etc.

Chunks are split at line boundaries to preserve content integrity.
