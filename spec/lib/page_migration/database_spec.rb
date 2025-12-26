# frozen_string_literal: true

RSpec.describe PageMigration::Database do
  describe ".connect" do
    context "when DATABASE_URL is set" do
      before do
        allow(Dotenv).to receive(:load)
        allow(ENV).to receive(:[]).with("DATABASE_URL").and_return("postgres://localhost/test")
        allow(PG).to receive(:connect).and_return(double("connection"))
      end

      it "connects to the database" do
        expect(PG).to receive(:connect).with("postgres://localhost/test")
        described_class.connect
      end
    end

    context "when DATABASE_URL is not set" do
      before do
        allow(Dotenv).to receive(:load)
        allow(ENV).to receive(:[]).with("DATABASE_URL").and_return(nil)
      end

      it "raises an error" do
        expect { described_class.connect }
          .to raise_error(PageMigration::Error, /DATABASE_URL not set/)
      end
    end
  end

  describe ".with_connection" do
    let(:mock_connection) { double("connection", close: nil) }

    before do
      allow(described_class).to receive(:connect).and_return(mock_connection)
    end

    it "yields a connection" do
      expect { |b| described_class.with_connection(&b) }.to yield_with_args(mock_connection)
    end

    it "closes the connection after the block" do
      expect(mock_connection).to receive(:close)
      described_class.with_connection { |_conn| }
    end

    it "closes the connection even if block raises" do
      expect(mock_connection).to receive(:close)
      expect { described_class.with_connection { raise "error" } }.to raise_error("error")
    end
  end
end
