# frozen_string_literal: true

RSpec.describe PageMigration::Commands::Health do
  let(:command) { described_class.new }

  describe "#call" do
    context "with all env vars set" do
      before do
        allow(ENV).to receive(:key?).and_return(true)
        allow(ENV).to receive(:[]).and_return("value")
        allow(ENV).to receive(:fetch).and_return("value")
        allow(PageMigration::Database).to receive(:with_connection).and_yield(double(exec: double(values: [[1]])))
      end

      it "returns true when all checks pass" do
        expect { command.call }.to output(/All checks passed/).to_stdout
      end
    end

    context "with missing env vars" do
      before do
        allow(ENV).to receive(:key?).and_return(false)
        allow(ENV).to receive(:[]).and_return(nil)
        allow(PageMigration::Database).to receive(:with_connection).and_raise(PG::Error.new("No connection"))
      end

      it "reports missing variables" do
        expect { command.call }.to output(/missing/).to_stdout
      end
    end
  end

  describe "#check_env_vars" do
    before do
      described_class::REQUIRED_ENV_VARS.each do |var|
        allow(ENV).to receive(:key?).with(var).and_return(true)
        allow(ENV).to receive(:[]).with(var).and_return("value")
      end
    end

    it "checks all required env vars" do
      expect { command.send(:check_env_vars) }.to output(/DATABASE_URL/).to_stdout
      expect { command.send(:check_env_vars) }.to output(/DUST_WORKSPACE_ID/).to_stdout
      expect { command.send(:check_env_vars) }.to output(/DUST_API_KEY/).to_stdout
      expect { command.send(:check_env_vars) }.to output(/DUST_AGENT_ID/).to_stdout
    end
  end

  describe "#check_database" do
    context "when connection succeeds" do
      let(:mock_conn) { double(exec: double(values: [[1]])) }

      before do
        allow(PageMigration::Database).to receive(:with_connection).and_yield(mock_conn)
      end

      it "returns true" do
        expect(command.send(:check_database)).to be true
      end

      it "outputs success message" do
        expect { command.send(:check_database) }.to output(/Connected successfully/).to_stdout
      end
    end

    context "when connection fails" do
      before do
        allow(PageMigration::Database).to receive(:with_connection).and_raise(PG::Error.new("Connection refused"))
      end

      it "returns false" do
        expect(command.send(:check_database)).to be false
      end

      it "outputs error message" do
        expect { command.send(:check_database) }.to output(/Connection failed/).to_stdout
      end
    end
  end

  describe "#check_dust_api" do
    context "when credentials are set" do
      before do
        allow(ENV).to receive(:[]).with("DUST_API_KEY").and_return("key")
        allow(ENV).to receive(:[]).with("DUST_WORKSPACE_ID").and_return("workspace")
      end

      it "returns true" do
        expect(command.send(:check_dust_api)).to be true
      end

      it "outputs client configured message" do
        expect { command.send(:check_dust_api) }.to output(/Client configured/).to_stdout
      end
    end

    context "when credentials are missing" do
      before do
        allow(ENV).to receive(:[]).with("DUST_API_KEY").and_return(nil)
        allow(ENV).to receive(:[]).with("DUST_WORKSPACE_ID").and_return(nil)
      end

      it "returns true (skipped check)" do
        expect(command.send(:check_dust_api)).to be true
      end

      it "outputs skipped message" do
        expect { command.send(:check_dust_api) }.to output(/Skipped/).to_stdout
      end
    end
  end
end
