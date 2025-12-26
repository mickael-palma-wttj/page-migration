# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module PageMigration
  module Dust
    # Simple client for the Dust API
    class Client
      BASE_URL = "https://dust.tt/api/v1"
      OPEN_TIMEOUT = 10

      attr_reader :workspace_id
      attr_accessor :debug

      def initialize(workspace_id, api_key, debug: false)
        @workspace_id = workspace_id
        @api_key = api_key
        @debug = debug
      end

      def create_conversation(title: nil, message: nil, blocking: true)
        path = "/w/#{@workspace_id}/assistant/conversations"
        payload = {
          title: title || "Migration Task #{Time.now.to_i}",
          visibility: "unlisted",
          blocking: blocking
        }
        payload[:message] = message if message

        post(path, payload)
      end

      def create_content_fragment(conversation_id, title, content)
        path = "/w/#{@workspace_id}/assistant/conversations/#{conversation_id}/content_fragments"
        payload = {
          title: title,
          content: content,
          contentType: "text/plain",
          context: default_context
        }

        post(path, payload)
      end

      def create_message(conversation_id, agent_id, content)
        path = "/w/#{@workspace_id}/assistant/conversations/#{conversation_id}/messages"
        payload = {
          content: content,
          mentions: [{configurationId: agent_id}],
          context: default_context,
          blocking: true
        }

        post(path, payload)
      end

      def get_conversation(conversation_id)
        path = "/w/#{@workspace_id}/assistant/conversations/#{conversation_id}"
        get(path)
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

      def post(path, payload)
        uri = URI("#{BASE_URL}#{path}")
        request = Net::HTTP::Post.new(uri)
        request.body = payload.to_json
        execute(uri, request)
      end

      def get(path)
        uri = URI("#{BASE_URL}#{path}")
        request = Net::HTTP::Get.new(uri)
        execute(uri, request)
      end

      def execute(uri, request)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = OPEN_TIMEOUT
        http.read_timeout = Config::DEFAULT_TIMEOUT

        response = http.request(request)
        handle_response(response)
      end

      def handle_response(response)
        unless response.is_a?(Net::HTTPSuccess)
          raise DustApiError.new(
            "Dust API Error: #{response.code}",
            status: response.code.to_i,
            response_body: response.body
          )
        end

        parsed = JSON.parse(response.body, symbolize_names: true)
        debug_response(parsed) if @debug
        parsed
      end

      def debug_response(data)
        puts "[DEBUG] Dust API Response:"
        puts JSON.pretty_generate(data).lines
        puts "... (truncated)" if JSON.pretty_generate(data).lines.length > 50
      end
    end
  end
end
