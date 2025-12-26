# frozen_string_literal: true

require "tempfile"
require "fileutils"

RSpec.describe PageMigration::Services::PromptProcessor do
  subject(:processor) { described_class.new(client, [], runner, language: "fr", debug: false) }

  let(:client) { instance_double(PageMigration::Dust::Client) }
  let(:runner) { instance_double(PageMigration::Dust::Runner) }
  let(:output_root) { Dir.mktmpdir }

  after { FileUtils.rm_rf(output_root) }

  describe "#process" do
    let(:prompt_file) { Tempfile.new(["test", ".prompt.md"]) }

    after { prompt_file.unlink }

    context "with YAML frontmatter" do
      before do
        prompt_file.write(<<~YAML)
          ---
          role: Content Writer
          task: Generate content
          output_format:
            type: json
          ---
          Write compelling content about the company.
        YAML
        prompt_file.rewind
      end

      it "parses YAML frontmatter and executes" do
        expect(runner).to receive(:run).and_return(content: '{"title": "Test"}', url: "https://dust.tt/conv/123")

        result = processor.process(prompt_file.path, "Summary content", output_root)
        expect(result).to eq('{"title": "Test"}')
      end

      it "saves result to output file" do
        allow(runner).to receive(:run).and_return(content: '{"title": "Test"}', url: nil)

        processor.process(prompt_file.path, "Summary content", output_root)

        # File is saved with the prompt name (without .prompt.md extension)
        output_files = Dir.glob(File.join(output_root, "**/*.json"))
        expect(output_files).not_to be_empty
      end
    end

    context "with JSON format" do
      before do
        prompt_file.write('{"role": "Writer", "task": "Write", "content": "Instructions", "output_format": {"type": "json"}}')
        prompt_file.rewind
      end

      it "parses JSON and executes" do
        expect(runner).to receive(:run).and_return(content: '{"result": "ok"}', url: nil)

        result = processor.process(prompt_file.path, "Summary", output_root)
        expect(result).to eq('{"result": "ok"}')
      end
    end

    context "with plain markdown" do
      before do
        prompt_file.write("Just some plain instructions for the agent.")
        prompt_file.rewind
      end

      it "uses default role and task" do
        expect(runner).to receive(:run) do |content, **_kwargs|
          expect(content).to include("Role: Content Analyst")
          {content: "Result", url: nil}
        end

        processor.process(prompt_file.path, "Summary", output_root)
      end
    end

    context "when save is false" do
      before do
        prompt_file.write("Instructions")
        prompt_file.rewind
      end

      it "does not save the result" do
        allow(runner).to receive(:run).and_return(content: "Result", url: nil)

        processor.process(prompt_file.path, "Summary", output_root, save: false)

        expect(Dir.glob(File.join(output_root, "*.json"))).to be_empty
      end
    end

    context "when runner returns nil" do
      before do
        prompt_file.write("Instructions")
        prompt_file.rewind
      end

      it "returns nil" do
        allow(runner).to receive(:run).and_return(nil)

        result = processor.process(prompt_file.path, "Summary", output_root)
        expect(result).to be_nil
      end
    end
  end

  describe "content chunking" do
    let(:prompt_file) { Tempfile.new(["test", ".prompt.md"]) }

    before do
      prompt_file.write("Instructions")
      prompt_file.rewind
    end

    after { prompt_file.unlink }

    it "splits large content into multiple fragments" do
      # Create content with multiple lines that exceeds MAX_FRAGMENT_SIZE
      line = "x" * 1000 + "\n"
      line_count = (PageMigration::Config::MAX_FRAGMENT_SIZE / line.bytesize) + 10
      large_content = line * line_count

      expect(runner).to receive(:run) do |_content, content_fragments:|
        expect(content_fragments.length).to be > 1
        expect(content_fragments.first[:title]).to include("Part 1")
        {content: "Result", url: nil}
      end

      processor.process(prompt_file.path, large_content, output_root)
    end

    it "keeps small content as single fragment" do
      small_content = "Small content"

      expect(runner).to receive(:run) do |_content, content_fragments:|
        expect(content_fragments.length).to eq(1)
        expect(content_fragments.first[:title]).to eq("Organization Data")
        {content: "Result", url: nil}
      end

      processor.process(prompt_file.path, small_content, output_root)
    end
  end

  describe "JSON extraction" do
    let(:prompt_file) { Tempfile.new(["test", ".prompt.md"]) }

    before do
      prompt_file.write("Instructions")
      prompt_file.rewind
    end

    after { prompt_file.unlink }

    it "extracts JSON from markdown code blocks" do
      response_with_markdown = "Here is the result:\n```json\n{\"title\": \"Test\"}\n```\nDone."
      allow(runner).to receive(:run).and_return(content: response_with_markdown, url: nil)

      processor.process(prompt_file.path, "Summary", output_root)

      output_files = Dir.glob(File.join(output_root, "**/*.json"))
      expect(output_files).not_to be_empty
      content = File.read(output_files.first)
      expect(JSON.parse(content)).to eq({"title" => "Test"})
    end

    it "extracts JSON from raw response" do
      response_with_extra = "Some text {\"title\": \"Test\"} more text"
      allow(runner).to receive(:run).and_return(content: response_with_extra, url: nil)

      processor.process(prompt_file.path, "Summary", output_root)

      output_files = Dir.glob(File.join(output_root, "**/*.json"))
      expect(output_files).not_to be_empty
      content = File.read(output_files.first)
      expect(JSON.parse(content)).to eq({"title" => "Test"})
    end
  end
end
