# frozen_string_literal: true

module PageMigration
  # Container module for all error classes
  module Errors
    # Base error class for all PageMigration errors
    class Base < StandardError; end

    # Raised when Dust API requests fail
    class DustApiError < Base
      attr_reader :status, :response_body

      def initialize(message, status: nil, response_body: nil)
        @status = status
        @response_body = response_body
        super(message)
      end
    end

    # Raised when parsing prompt files fails
    class ParseError < Base
      attr_reader :file_path

      def initialize(message, file_path: nil)
        @file_path = file_path
        super(message)
      end
    end

    # Raised when database operations fail
    class DatabaseError < Base; end

    # Raised when required files are not found
    class FileNotFoundError < Base
      attr_reader :file_path

      def initialize(message, file_path: nil)
        @file_path = file_path
        super(message)
      end
    end

    # Raised when input validation fails
    class ValidationError < Base; end
  end

  # Short aliases for convenience
  Error = Errors::Base
  DustApiError = Errors::DustApiError
  ParseError = Errors::ParseError
  DatabaseError = Errors::DatabaseError
  FileNotFoundError = Errors::FileNotFoundError
  ValidationError = Errors::ValidationError
end
