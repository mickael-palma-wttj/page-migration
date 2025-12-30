# frozen_string_literal: true

RSpec.describe PageMigration::CliRunner do
  describe "#call" do
    context "with no arguments" do
      it "shows help text" do
        runner = described_class.new([])
        expect { runner.call }.to output(/Page Migration CLI/).to_stdout
      end
    end

    context "with -h flag" do
      it "shows help text" do
        runner = described_class.new(["-h"])
        expect { runner.call }.to output(/Page Migration CLI/).to_stdout
      end
    end

    context "with --help flag" do
      it "shows help text" do
        runner = described_class.new(["--help"])
        expect { runner.call }.to output(/Page Migration CLI/).to_stdout
      end
    end

    context "with unknown command" do
      it "shows error and help text" do
        runner = described_class.new(["unknown"])
        expect { runner.call }.to output(/Unknown command: unknown/).to_stdout
      end
    end
  end

  describe "COMMANDS" do
    it "includes all expected commands" do
      expect(described_class::COMMANDS).to contain_exactly(
        "extract", "tree", "export", "migrate", "health", "app", "stats"
      )
    end
  end

  describe "extract command" do
    let(:runner) { described_class.new(["extract", "Pg4eV6k"]) }

    before do
      allow(PageMigration::Commands::Extract).to receive(:new).and_return(double(call: nil))
    end

    it "validates org_ref format" do
      expect { runner.call }.not_to raise_error
    end

    context "with invalid org_ref" do
      let(:runner) { described_class.new(["extract"]) }

      it "aborts with validation error" do
        expect { runner.call }.to raise_error(SystemExit)
      end
    end

    context "with format option" do
      let(:runner) { described_class.new(["extract", "Pg4eV6k", "-f", "simple-json"]) }

      it "passes format to command" do
        expect(PageMigration::Commands::Extract).to receive(:new)
          .with("Pg4eV6k", hash_including(format: "simple-json"))
          .and_return(double(call: nil))
        runner.call
      end
    end
  end

  describe "tree command" do
    let(:runner) { described_class.new(["tree", "Pg4eV6k"]) }

    before do
      allow(PageMigration::Commands::ExtractTree).to receive(:new).and_return(double(call: nil))
    end

    it "creates ExtractTree command" do
      expect(PageMigration::Commands::ExtractTree).to receive(:new)
        .with("Pg4eV6k")
        .and_return(double(call: nil))
      runner.call
    end
  end

  describe "export command" do
    let(:runner) { described_class.new(["export", "Pg4eV6k"]) }

    before do
      allow(PageMigration::Commands::Export).to receive(:new).and_return(double(call: nil))
    end

    it "creates Export command" do
      expect(PageMigration::Commands::Export).to receive(:new)
        .with("Pg4eV6k", anything)
        .and_return(double(call: nil))
      runner.call
    end

    context "with languages option" do
      let(:runner) { described_class.new(["export", "Pg4eV6k", "-l", "fr,en,cs"]) }

      it "passes validated languages" do
        expect(PageMigration::Commands::Export).to receive(:new)
          .with("Pg4eV6k", hash_including(languages: %w[fr en cs]))
          .and_return(double(call: nil))
        runner.call
      end
    end
  end

  describe "migrate command" do
    let(:runner) { described_class.new(["migrate", "Pg4eV6k"]) }

    before do
      allow(PageMigration::Commands::Migrate).to receive(:new).and_return(double(call: nil))
    end

    it "creates Migrate command" do
      expect(PageMigration::Commands::Migrate).to receive(:new)
        .with("Pg4eV6k", anything)
        .and_return(double(call: nil))
      runner.call
    end

    context "with analysis flag" do
      let(:runner) { described_class.new(["migrate", "Pg4eV6k", "--analysis"]) }

      it "passes analysis option" do
        expect(PageMigration::Commands::Migrate).to receive(:new)
          .with("Pg4eV6k", hash_including(analysis: true))
          .and_return(double(call: nil))
        runner.call
      end
    end
  end
end
