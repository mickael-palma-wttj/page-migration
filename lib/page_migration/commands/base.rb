# frozen_string_literal: true

module PageMigration
  module Commands
    # Base class for all commands providing shared functionality
    class Base
      include Loggable

      attr_reader :org_ref

      def initialize(org_ref, **options)
        @org_ref = org_ref
        @debug = options[:debug] || false
      end

      def call
        raise NotImplementedError, "#{self.class}#call must be implemented"
      end

      private

      def output_dir(org_name)
        Config.output_dir(@org_ref, org_name)
      end

      def with_database(&block)
        Database.with_connection(&block)
      rescue PG::Error => e
        raise Errors::DatabaseError, "Database error: #{e.message}"
      end

      def success(message)
        puts "✅ #{message}"
      end

      def info(message)
        puts "📋 #{message}"
      end

      def warn(message)
        puts "⚠️ #{message}"
      end
    end
  end
end
