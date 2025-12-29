# frozen_string_literal: true

RSpec.describe PageMigration::Commands::Base do
  let(:test_command_class) do
    Class.new(described_class) do
      def call
        "executed"
      end
    end
  end

  describe "#initialize" do
    it "sets org_ref" do
      command = test_command_class.new("TestRef")
      expect(command.org_ref).to eq("TestRef")
    end

    it "defaults debug to false" do
      command = test_command_class.new("TestRef")
      expect(command.instance_variable_get(:@debug)).to be false
    end

    it "accepts debug option" do
      command = test_command_class.new("TestRef", debug: true)
      expect(command.instance_variable_get(:@debug)).to be true
    end
  end

  describe "#call" do
    it "raises NotImplementedError for base class" do
      command = described_class.new("TestRef")
      expect { command.call }.to raise_error(NotImplementedError)
    end

    it "can be implemented by subclasses" do
      command = test_command_class.new("TestRef")
      expect(command.call).to eq("executed")
    end
  end

  describe "#output_dir" do
    it "delegates to Config.output_dir" do
      command = test_command_class.new("TestRef")
      expect(PageMigration::Config).to receive(:output_dir).with("TestRef", "Org Name")
      command.send(:output_dir, "Org Name")
    end
  end

  describe "#with_database" do
    let(:mock_conn) { double("connection") }

    before do
      allow(PageMigration::Database).to receive(:with_connection).and_yield(mock_conn)
    end

    it "yields a database connection" do
      command = test_command_class.new("TestRef")
      result = nil
      command.send(:with_database) { |conn| result = conn }
      expect(result).to eq(mock_conn)
    end

    context "when database error occurs" do
      before do
        allow(PageMigration::Database).to receive(:with_connection).and_raise(PG::Error.new("Connection failed"))
      end

      it "raises DatabaseError" do
        command = test_command_class.new("TestRef")
        expect { command.send(:with_database) { } }
          .to raise_error(PageMigration::Errors::DatabaseError, /Database error/)
      end
    end
  end

  describe "output helpers" do
    let(:command) { test_command_class.new("TestRef") }

    it "outputs success message" do
      expect { command.send(:success, "Done") }.to output(/✅ Done/).to_stdout
    end

    it "outputs info message" do
      expect { command.send(:info, "Status") }.to output(/📋 Status/).to_stdout
    end

    it "outputs warning message" do
      expect { command.send(:warn, "Warning") }.to output(/⚠️ Warning/).to_stdout
    end
  end
end
