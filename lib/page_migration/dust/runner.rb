# frozen_string_literal: true

require "ruby-progressbar"

module PageMigration
  module Dust
    # Handles the execution of a Dust Agent run
    class Runner
      def initialize(client, agent_id)
        @client = client
        @agent_id = agent_id
      end

      def run(user_content, content_fragments: [])
        # 1. Create conversation
        conv_response = @client.create_conversation(
          title: "Migration Task #{Time.now.to_i}",
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

        # 2. Add content fragments
        content_fragments.each do |fragment|
          @client.create_content_fragment(conv_id, fragment[:title], fragment[:content])
        end

        # 3. Create message with agent mention and blocking: true
        @client.create_message(conv_id, @agent_id, user_content)

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
