# frozen_string_literal: true

require "faraday"
require "json"

module PageMigration
  module Dust
    # Simple client for the Dust API
    class Client
      BASE_URL = "https://dust.tt/api/v1"
      DEFAULT_TIMEOUT = 300
      OPEN_TIMEOUT = 10

      attr_reader :workspace_id

      def initialize(workspace_id, api_key)
        @workspace_id = workspace_id
        @api_key = api_key
      end

      def create_conversation(title: nil, message: nil)
        url = "#{BASE_URL}/w/#{@workspace_id}/assistant/conversations"
        payload = {
          title: title || "Migration Task #{Time.now.to_i}",
          visibility: "unlisted"
        }
        payload[:message] = message if message

        response = connection.post(url) { |req| req.body = payload.to_json }
        handle_response(response)
      end

      def create_content_fragment(conversation_id, title, content)
        url = "#{BASE_URL}/w/#{@workspace_id}/assistant/conversations/#{conversation_id}/content_fragments"
        payload = {
          title: title,
          content: content,
          contentType: "text/plain",
          context: default_context
        }

        response = connection.post(url) { |req| req.body = payload.to_json }
        handle_response(response)
      end

      def create_message(conversation_id, agent_id, content)
        url = "#{BASE_URL}/w/#{@workspace_id}/assistant/conversations/#{conversation_id}/messages"
        payload = {
          content: content,
          mentions: [{configurationId: agent_id}],
          context: default_context,
          blocking: true
        }

        response = connection.post(url) { |req| req.body = payload.to_json }
        handle_response(response)
      end

      def get_conversation(conversation_id)
        url = "#{BASE_URL}/w/#{@workspace_id}/assistant/conversations/#{conversation_id}"
        response = connection.get(url)
        handle_response(response)
      end

      private

      def default_context
        {
          timezone: "Europe/Paris",
          username: "page-migration-bot",
          fullName: "Page Migration Bot",
          email: "bot@example.com",
          profilePictureUrl: "",
          origin: "api"
        }
      end

      def connection
        @connection ||= Faraday.new do |f|
          f.headers["Authorization"] = "Bearer #{@api_key}"
          f.headers["Content-Type"] = "application/json"
          f.options.timeout = DEFAULT_TIMEOUT
          f.options.open_timeout = OPEN_TIMEOUT
          f.adapter Faraday.default_adapter
        end
      end

      def handle_response(response)
        raise "Dust API Error: #{response.status} - #{response.body}" unless response.success?

        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
