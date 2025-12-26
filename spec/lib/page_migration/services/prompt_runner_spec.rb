# frozen_string_literal: true

RSpec.describe PageMigration::Services::PromptRunner do
  let(:processor) { instance_double(PageMigration::Services::PromptProcessor) }
  let(:prompts) { ["/path/prompt1.md", "/path/prompt2.md"] }
  let(:summary) { "Organization summary content" }
  let(:output_root) { "/tmp/output" }

  describe "#run" do
    context "in debug mode (sequential)" do
      subject(:runner) { described_class.new(processor, debug: true) }

      it "processes prompts sequentially" do
        expect(processor).to receive(:process).with(prompts[0], summary, output_root, additional_instructions: nil).ordered
        expect(processor).to receive(:process).with(prompts[1], summary, output_root, additional_instructions: nil).ordered

        runner.run(prompts, summary, output_root)
      end

      it "passes additional instructions" do
        instructions = "Custom guidelines"
        expect(processor).to receive(:process).with(prompts[0], summary, output_root, additional_instructions: instructions)
        expect(processor).to receive(:process).with(prompts[1], summary, output_root, additional_instructions: instructions)

        runner.run(prompts, summary, output_root, additional_instructions: instructions)
      end
    end

    context "in parallel mode" do
      subject(:runner) { described_class.new(processor, debug: false) }

      let(:progress_bar) { instance_double(ProgressBar::Base, increment: nil) }

      before do
        allow(ProgressBar).to receive(:create).and_return(progress_bar)
      end

      it "processes prompts in parallel" do
        expect(processor).to receive(:process).twice

        runner.run(prompts, summary, output_root)
      end

      it "increments progress bar for each prompt" do
        allow(processor).to receive(:process)
        expect(progress_bar).to receive(:increment).twice

        runner.run(prompts, summary, output_root)
      end

      it "handles errors gracefully" do
        allow(processor).to receive(:process).with(prompts[0], anything, anything, anything).and_raise(StandardError.new("API Error"))
        allow(processor).to receive(:process).with(prompts[1], anything, anything, anything)

        expect { runner.run(prompts, summary, output_root) }.to output(/Some prompts failed/).to_stdout
      end
    end
  end
end
