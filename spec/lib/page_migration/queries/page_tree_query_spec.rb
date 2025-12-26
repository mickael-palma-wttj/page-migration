# frozen_string_literal: true

RSpec.describe PageMigration::Queries::PageTreeQuery do
  let(:org_ref) { "Pg4eV6k" }
  let(:query) { described_class.new(org_ref) }

  describe "#call" do
    let(:mock_conn) { double("connection") }
    let(:result_data) { {"tree_data" => '{"page_tree": []}'} }
    let(:mock_result) { double("result", ntuples: 1, first: result_data) }

    context "when organization exists" do
      before do
        allow(mock_conn).to receive(:exec_params).and_return(mock_result)
      end

      it "executes the SQL query with org_ref" do
        expect(mock_conn).to receive(:exec_params)
          .with(PageMigration::Queries::PageTreeSql::SQL, [org_ref])
        query.call(mock_conn)
      end

      it "returns the tree_data from the result" do
        expect(query.call(mock_conn)).to eq('{"page_tree": []}')
      end
    end

    context "when organization not found" do
      let(:empty_result) { double("result", ntuples: 0) }

      before do
        allow(mock_conn).to receive(:exec_params).and_return(empty_result)
      end

      it "raises an error" do
        expect { query.call(mock_conn) }
          .to raise_error(PageMigration::Error, /No data found for organization: #{org_ref}/)
      end
    end
  end
end
