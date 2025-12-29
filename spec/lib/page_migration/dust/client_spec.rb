# frozen_string_literal: true

RSpec.describe PageMigration::Dust::Client do
  subject(:client) { described_class.new(workspace_id, api_key) }

  let(:workspace_id) { "test_workspace" }
  let(:api_key) { "test_api_key" }

  describe "#initialize" do
    it "sets workspace_id" do
      expect(client.workspace_id).to eq(workspace_id)
    end

    it "defaults debug to false" do
      expect(client.debug).to be false
    end

    it "accepts debug option" do
      client = described_class.new(workspace_id, api_key, debug: true)
      expect(client.debug).to be true
    end
  end

  describe "#create_conversation" do
    let(:response_body) { {conversation: {sId: "conv_123"}}.to_json }

    before do
      stub_request(:post, "https://dust.tt/api/v1/w/#{workspace_id}/assistant/conversations")
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
    end

    it "creates a conversation" do
      result = client.create_conversation(title: "Test")
      expect(result[:conversation][:sId]).to eq("conv_123")
    end

    it "sends correct headers" do
      client.create_conversation
      expect(WebMock).to have_requested(:post, /conversations/)
        .with(headers: {"Authorization" => "Bearer #{api_key}", "Content-Type" => "application/json"})
    end
  end

  describe "#create_content_fragment" do
    let(:conversation_id) { "conv_123" }
    let(:response_body) { {contentFragment: {id: "frag_1"}}.to_json }

    before do
      stub_request(:post, "https://dust.tt/api/v1/w/#{workspace_id}/assistant/conversations/#{conversation_id}/content_fragments")
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
    end

    it "creates a content fragment" do
      result = client.create_content_fragment(conversation_id, "Title", "Content")
      expect(result[:contentFragment][:id]).to eq("frag_1")
    end
  end

  describe "#create_message" do
    let(:conversation_id) { "conv_123" }
    let(:agent_id) { "agent_456" }
    let(:response_body) { {message: {id: "msg_1"}}.to_json }

    before do
      stub_request(:post, "https://dust.tt/api/v1/w/#{workspace_id}/assistant/conversations/#{conversation_id}/messages")
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
    end

    it "creates a message with agent mention" do
      result = client.create_message(conversation_id, agent_id, "Hello")
      expect(result[:message][:id]).to eq("msg_1")
    end
  end

  describe "#get_conversation" do
    let(:conversation_id) { "conv_123" }
    let(:response_body) { {conversation: {sId: conversation_id, content: []}}.to_json }

    before do
      stub_request(:get, "https://dust.tt/api/v1/w/#{workspace_id}/assistant/conversations/#{conversation_id}")
        .to_return(status: 200, body: response_body, headers: {"Content-Type" => "application/json"})
    end

    it "retrieves the conversation" do
      result = client.get_conversation(conversation_id)
      expect(result[:conversation][:sId]).to eq(conversation_id)
    end
  end

  describe "error handling" do
    context "with non-retryable error (400)" do
      before do
        stub_request(:post, "https://dust.tt/api/v1/w/#{workspace_id}/assistant/conversations")
          .to_return(status: 400, body: '{"error": "Bad Request"}', headers: {"Content-Type" => "application/json"})
      end

      it "raises DustApiError immediately" do
        expect { client.create_conversation }
          .to raise_error(PageMigration::Errors::DustApiError) do |error|
            expect(error.status).to eq(400)
            expect(error.response_body).to eq('{"error": "Bad Request"}')
          end
      end
    end

    context "with retryable error (500)" do
      before do
        stub_request(:post, "https://dust.tt/api/v1/w/#{workspace_id}/assistant/conversations")
          .to_return(status: 500, body: '{"error": "Internal"}', headers: {"Content-Type" => "application/json"})
      end

      it "retries and eventually raises DustApiError" do
        expect { client.create_conversation }
          .to raise_error(PageMigration::Errors::DustApiError) do |error|
            expect(error.status).to eq(500)
          end
      end
    end
  end
end
