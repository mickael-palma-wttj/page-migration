# frozen_string_literal: true

RSpec.describe PageMigration::Dust::Runner do
  let(:client) { instance_double(PageMigration::Dust::Client, workspace_id: "test_ws") }
  let(:agent_id) { "agent_123" }
  let(:runner) { described_class.new(client, agent_id) }

  describe "#run" do
    let(:conv_response) { {conversation: {sId: "conv_1"}} }
    let(:message_response) { {message: {id: "msg_1"}} }
    let(:get_response) do
      {
        conversation: {
          sId: "conv_1",
          content: [
            [{type: "user_message", content: "Hello"}],
            [{type: "agent_message", status: "succeeded", content: "Response text"}]
          ]
        }
      }
    end

    before do
      allow(client).to receive(:create_conversation).and_return(conv_response)
      allow(client).to receive(:create_content_fragment)
      allow(client).to receive(:create_message).and_return(message_response)
      allow(client).to receive(:get_conversation).and_return(get_response)
    end

    it "creates a conversation" do
      expect(client).to receive(:create_conversation)
      runner.run("Test prompt")
    end

    it "creates a message with the agent" do
      expect(client).to receive(:create_message).with("conv_1", agent_id, "Test prompt")
      runner.run("Test prompt")
    end

    it "returns the agent response content" do
      result = runner.run("Test prompt")
      expect(result[:content]).to eq("Response text")
    end

    it "returns the conversation URL" do
      result = runner.run("Test prompt")
      expect(result[:url]).to eq("https://dust.tt/w/test_ws/conversation/conv_1")
    end

    context "with content fragments" do
      let(:fragments) { [{title: "Data", content: "Some content"}] }

      it "uploads content fragments" do
        expect(client).to receive(:create_content_fragment).with("conv_1", "Data", "Some content")
        runner.run("Test", content_fragments: fragments)
      end
    end

    context "when agent message is failed" do
      let(:get_response) do
        {
          conversation: {
            sId: "conv_1",
            content: [
              [{type: "agent_message", status: "failed", content: ""}]
            ]
          }
        }
      end

      it "returns nil" do
        result = runner.run("Test")
        expect(result).to be_nil
      end
    end

    context "when no agent message found" do
      let(:get_response) do
        {
          conversation: {
            sId: "conv_1",
            content: [[{type: "user_message", content: "Hello"}]]
          }
        }
      end

      it "returns nil" do
        result = runner.run("Test")
        expect(result).to be_nil
      end
    end

    context "when response uses contents array" do
      let(:get_response) do
        {
          conversation: {
            sId: "conv_1",
            content: [
              [{
                type: "agent_message",
                status: "succeeded",
                content: "",
                contents: [{content: {type: "text", value: "Text from contents"}}]
              }]
            ]
          }
        }
      end

      it "extracts text from contents array" do
        result = runner.run("Test")
        expect(result[:content]).to eq("Text from contents")
      end
    end
  end
end
