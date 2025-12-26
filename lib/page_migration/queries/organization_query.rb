# frozen_string_literal: true

module PageMigration
  module Queries
    # Encapsulates the SQL query logic for organization data
    class OrganizationQuery
      def initialize(org_ref)
        @org_ref = org_ref
      end

      def call(conn)
        result = conn.exec_params(OrganizationSql::SQL, [@org_ref])
        raise PageMigration::Error, "No data found for organization: #{@org_ref}" if result.ntuples.zero?

        result.first["data"]
      end
    end
  end
end
