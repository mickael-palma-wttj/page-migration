# Dust API Integration

Client and runner for interacting with the Dust AI platform.

## Components

### Client (`client.rb`)

Low-level HTTP client for the Dust API.

**Methods:**

| Method | Description |
|--------|-------------|
| `create_conversation(title:, message:)` | Creates a new conversation |
| `create_content_fragment(conversation_id, title, content)` | Adds a content fragment (max 512KB) |
| `create_message(conversation_id, agent_id, content)` | Sends a message to an agent |
| `get_conversation(conversation_id)` | Retrieves conversation with responses |

**Configuration:**
- `BASE_URL`: `https://dust.tt/api/v1`
- `DEFAULT_TIMEOUT`: 300 seconds
- `OPEN_TIMEOUT`: 10 seconds

### Runner (`runner.rb`)

High-level orchestrator for running Dust agent tasks.

**Usage:**

```ruby
client = PageMigration::Dust::Client.new(workspace_id, api_key)
runner = PageMigration::Dust::Runner.new(client, agent_id)

result = runner.run(
  "Your prompt here",
  content_fragments: [
    { title: "Data", content: "Large content..." }
  ]
)

puts result[:content]  # Agent's response
puts result[:url]      # Conversation URL
```

**Workflow:**
1. Creates a new conversation
2. Uploads content fragments (for large data)
3. Sends message with agent mention
4. Waits for agent response (blocking)
5. Extracts and returns the response text

## API Limits

| Resource | Limit |
|----------|-------|
| Message body | 1 MB |
| Content fragment | 512 KB |

For content larger than 512KB, use the chunking mechanism in `PromptProcessor`.
