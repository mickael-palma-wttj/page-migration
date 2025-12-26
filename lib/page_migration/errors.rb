# frozen_string_literal: true

module PageMigration
  # Base error class for all PageMigration errors
  class Error < StandardError; end

  # Raised when Dust API requests fail
  class DustApiError < Error
    attr_reader :status, :response_body

    def initialize(message, status: nil, response_body: nil)
      @status = status
      @response_body = response_body
      super(message)
    end
  end

  # Raised when parsing prompt files fails
  class ParseError < Error
    attr_reader :file_path

    def initialize(message, file_path: nil)
      @file_path = file_path
      super(message)
    end
  end

  # Raised when database operations fail
  class DatabaseError < Error; end

  # Raised when required files are not found
  class FileNotFoundError < Error
    attr_reader :file_path

    def initialize(message, file_path: nil)
      @file_path = file_path
      super(message)
    end
  end

  # Raised when input validation fails
  class ValidationError < Error; end
end
