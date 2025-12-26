# frozen_string_literal: true

module PageMigration
  # Input validation utilities
  module Validator
    # Organization reference format: alphanumeric, 5-10 characters
    ORG_REF_PATTERN = /\A[A-Za-z0-9]{5,10}\z/

    # Supported languages
    SUPPORTED_LANGUAGES = %w[fr en cs de es it pt].freeze

    # Supported formats
    SUPPORTED_FORMATS = %w[json text].freeze

    class << self
      def validate_org_ref!(org_ref)
        raise ValidationError, "Organization reference is required" if org_ref.nil? || org_ref.empty?
        raise ValidationError, "Invalid organization reference format: #{org_ref}" unless org_ref.match?(ORG_REF_PATTERN)

        org_ref
      end

      def validate_language!(language)
        return "fr" if language.nil?

        unless SUPPORTED_LANGUAGES.include?(language)
          raise ValidationError, "Unsupported language: #{language}. Supported: #{SUPPORTED_LANGUAGES.join(", ")}"
        end

        language
      end

      def validate_languages!(languages)
        return %w[fr en] if languages.nil? || languages.empty?

        invalid = languages - SUPPORTED_LANGUAGES
        unless invalid.empty?
          raise ValidationError, "Unsupported languages: #{invalid.join(", ")}. Supported: #{SUPPORTED_LANGUAGES.join(", ")}"
        end

        languages
      end

      def validate_format!(format)
        return "json" if format.nil?

        unless SUPPORTED_FORMATS.include?(format)
          raise ValidationError, "Unsupported format: #{format}. Supported: #{SUPPORTED_FORMATS.join(", ")}"
        end

        format
      end

      def validate_file_exists!(path)
        raise FileNotFoundError.new("File not found: #{path}", file_path: path) unless File.exist?(path)

        path
      end

      def validate_directory_exists!(path)
        raise FileNotFoundError.new("Directory not found: #{path}", file_path: path) unless Dir.exist?(path)

        path
      end
    end
  end
end
