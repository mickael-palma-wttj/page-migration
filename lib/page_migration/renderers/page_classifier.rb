# frozen_string_literal: true

module PageMigration
  module Renderers
    # Classifies pages based on their slug patterns
    class PageClassifier
      PATTERNS = {
        "profil" => ->(slug) { slug == "/" },
        "jobs" => ->(slug) { slug.downcase.include?("job") },
        "team" => ->(slug) { slug.downcase.include?("team") || slug.downcase.include?("equipe") },
        "tech" => ->(slug) { slug.downcase.include?("tech") },
        "culture" => ->(slug) { slug.downcase.include?("culture") },
        "benefits" => ->(slug) { slug.downcase.include?("plus") },
        "office_and_remote" => lambda { |slug|
          s = slug.downcase
          s.include?("bureau") || s.include?("office") || s.include?("teletravail") || s.include?("remote")
        },
        "event" => ->(slug) { slug.downcase.include?("meeting") },
        "featured" => ->(slug) { slug.downcase.include?("featured") }
      }.freeze

      def self.classify(slug)
        return "custom" if slug.nil?

        PATTERNS.each do |category, matcher|
          return category if matcher.call(slug)
        end

        "custom"
      end

      def self.custom?(slug)
        classify(slug) == "custom"
      end

      def self.standard?(slug)
        !custom?(slug)
      end
    end
  end
end
