# frozen_string_literal: true

RSpec.describe PageMigration::Commands::Migrate do
  let(:org_ref) { "Pg4eV6k" }
  let(:org_data) do
    [{
      "name" => "Test Company",
      "reference" => org_ref,
      "pages" => []
    }]
  end

  before do
    allow(ENV).to receive(:fetch).with("DUST_WORKSPACE_ID").and_return("workspace_123")
    allow(ENV).to receive(:fetch).with("DUST_API_KEY").and_return("api_key_123")
    allow(ENV).to receive(:fetch).with("DUST_AGENT_ID").and_return("agent_123")
    allow(PageMigration::Support::JsonLoader).to receive(:load).and_return(org_data)
    allow(PageMigration::Support::FileDiscovery).to receive(:find_query_json).and_return("tmp/query.json")
    allow(PageMigration::Support::FileDiscovery).to receive(:find_text_content).and_return("tmp/content.txt")
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return("Content text")
    allow(FileUtils).to receive(:mkdir_p)
  end

  describe "#initialize" do
    it "initializes Dust client" do
      expect(PageMigration::Dust::Client).to receive(:new)
        .with("workspace_123", "api_key_123", debug: false)
        .and_call_original
      described_class.new(org_ref)
    end

    it "accepts debug option" do
      expect(PageMigration::Dust::Client).to receive(:new)
        .with("workspace_123", "api_key_123", debug: true)
        .and_call_original
      described_class.new(org_ref, debug: true)
    end
  end

  describe "#call" do
    let(:mock_processor) { instance_double(PageMigration::Services::PromptProcessor) }
    let(:mock_runner) { instance_double(PageMigration::Services::PromptRunner) }
    let(:mock_dust_runner) { instance_double(PageMigration::Dust::Runner) }

    before do
      allow(PageMigration::Dust::Runner).to receive(:new).and_return(mock_dust_runner)
      allow(PageMigration::Services::PromptProcessor).to receive(:new).and_return(mock_processor)
      allow(PageMigration::Services::PromptRunner).to receive(:new).and_return(mock_runner)
    end

    context "with analysis_only option" do
      let(:command) { described_class.new(org_ref, analysis: true) }

      before do
        allow(mock_processor).to receive(:process).and_return("Analysis result")
        allow(File).to receive(:write)
      end

      it "runs analysis prompt only" do
        expect(mock_processor).to receive(:process).with(
          /analysis\.prompt\.md$/,
          anything,
          anything,
          hash_including(save: false)
        )
        expect { command.call }.to output(/Running page migration fit analysis/).to_stdout
      end

      it "writes analysis output" do
        expect(File).to receive(:write).with(/analysis\.md$/, anything)
        expect { command.call }.to output.to_stdout
      end
    end

    context "full migration workflow" do
      let(:command) { described_class.new(org_ref) }

      before do
        allow(mock_processor).to receive(:process).and_return("Result")
        allow(mock_runner).to receive(:run)
        allow(Dir).to receive(:glob).and_return([])
      end

      it "runs brand analysis first" do
        expect(mock_processor).to receive(:process).with(/file_analysis\.prompt\.md$/, anything, anything)
        expect { command.call }.to output(/Running brand analysis/).to_stdout
      end

      it "runs prompt runner with prompts" do
        expect(mock_runner).to receive(:run)
        expect { command.call }.to output.to_stdout
      end
    end

    context "when text content not found" do
      let(:command) { described_class.new(org_ref) }
      let(:extract_command) { instance_double(PageMigration::Commands::Extract, call: nil) }

      before do
        allow(PageMigration::Support::FileDiscovery).to receive(:find_text_content).and_return(nil)
        allow(PageMigration::Commands::Extract).to receive(:new).and_return(extract_command)
        allow(mock_processor).to receive(:process)
        allow(mock_runner).to receive(:run)
        allow(Dir).to receive(:glob).and_return([])
      end

      it "runs extract with text format" do
        expect(PageMigration::Commands::Extract).to receive(:new)
          .with(org_ref, format: "text", language: "fr")
        # Will raise because text file still not found after extract
        expect { command.call }.to raise_error(PageMigration::Error, /Text extraction failed/)
      end
    end
  end
end
