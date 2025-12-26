# frozen_string_literal: true

require "ruby-progressbar"

module PageMigration
  module Dust
    # Handles the execution of a Dust Agent run
    class Runner
      include Loggable

      def initialize(client, agent_id, debug: false)
        @client = client
        @agent_id = agent_id
        @debug = debug
      end

      def run(user_content, content_fragments: [])
        # 1. Create conversation
        debug_log "Creating conversation..."
        conv_response = @client.create_conversation(
          title: "Migration Task #{Time.now.to_i}",
          blocking: true,
          message: {
            content: "Starting migration task...",
            mentions: [],
            context: {
              timezone: "Europe/Paris",
              username: "page-migration-bot",
              fullName: "Page Migration Bot",
              email: "bot@example.com",
              origin: "api"
            }
          }
        )
        conv_id = conv_response.dig(:conversation, :sId)
        debug_log "  Conversation ID: #{conv_id}"

        # 2. Add content fragments
        content_fragments.each_with_index do |fragment, idx|
          debug_log "  Uploading fragment #{idx + 1}/#{content_fragments.length}: #{fragment[:title]} (#{fragment[:content].bytesize} bytes)"
          @client.create_content_fragment(conv_id, fragment[:title], fragment[:content])
        end

        # 3. Create message with agent mention and blocking: true
        debug_log "  Sending message to agent (#{user_content.length} chars)..."
        start_time = Time.now
        @client.create_message(conv_id, @agent_id, user_content)
        elapsed = Time.now - start_time
        debug_log "  Agent responded in #{elapsed.round(2)}s"

        # 4. Fetch conversation to get the agent's response
        response = @client.get_conversation(conv_id)

        content = extract_response(response)
        return nil unless content

        {content: content, url: build_url(response)}
      end

      private

      def build_url(response)
        id = response.dig(:conversation, :sId)
        "https://dust.tt/w/#{@client.workspace_id}/conversation/#{id}"
      end

      def extract_response(response)
        messages = response.dig(:conversation, :content)
        return nil unless messages

        agent_message = messages.flatten.reverse.find { |m| m[:type] == "agent_message" }
        return nil if agent_message.nil? || agent_message[:status] == "failed"

        extract_text(agent_message)
      end

      def extract_text(message)
        return message[:content] if message[:content] && !message[:content].empty?

        contents = message[:contents] || []
        text_content = contents.find { |c| c.dig(:content, :type) == "text" }
        text_content&.dig(:content, :value)
      end
    end
  end
end
