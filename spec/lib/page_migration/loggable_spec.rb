# frozen_string_literal: true

RSpec.describe PageMigration::Loggable do
  let(:test_class) do
    Class.new do
      include PageMigration::Loggable

      attr_accessor :debug

      def initialize(debug: false)
        @debug = debug
      end
    end
  end

  describe "#debug_log" do
    context "when debug is true" do
      let(:instance) { test_class.new(debug: true) }

      it "outputs message with [DEBUG] prefix" do
        expect { instance.debug_log("Test message") }
          .to output("[DEBUG] Test message\n").to_stdout
      end
    end

    context "when debug is false" do
      let(:instance) { test_class.new(debug: false) }

      it "outputs nothing" do
        expect { instance.debug_log("Test message") }
          .not_to output.to_stdout
      end
    end
  end
end
