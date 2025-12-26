# frozen_string_literal: true

module PageMigration
  module Queries
    # Encapsulates the SQL query logic for page tree hierarchy
    class PageTreeQuery
      def initialize(org_ref)
        @org_ref = org_ref
      end

      def call(conn)
        result = conn.exec_params(PageTreeSql::SQL, [@org_ref])
        raise PageMigration::Error, "No data found for organization: #{@org_ref}" if result.ntuples.zero?

        result.first["tree_data"]
      end
    end
  end
end
