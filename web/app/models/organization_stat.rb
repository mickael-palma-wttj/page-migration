# frozen_string_literal: true

# Non-ActiveRecord model for organization statistics
# Wraps OrganizationQuery.stats and provides domain logic
class OrganizationStat
  SIZES = %w[big medium small].freeze
  SIZE_THRESHOLDS = {big: 10, medium: 2}.freeze

  attr_reader :reference, :name, :total_pages, :published_pages,
    :latest_published_at, :size_category

  def initialize(reference:, name:, total_pages:, published_pages:,
    latest_published_at:, size_category:)
    @reference = reference
    @name = name
    @total_pages = total_pages
    @published_pages = published_pages
    @latest_published_at = latest_published_at
    @size_category = size_category
  end

  def big?
    size_category == "big"
  end

  def medium?
    size_category == "medium"
  end

  def small?
    size_category == "small"
  end

  def to_param
    reference
  end

  def to_csv_row
    [reference, name, total_pages, published_pages, latest_published_at, size_category]
  end

  class << self
    def all(size: nil)
      OrganizationQuery.stats(size: size).map { |row| from_hash(row) }
    end

    def summary(stats)
      by_size = stats.group_by(&:size_category)
      {
        total: stats.size,
        big: by_size["big"]&.size || 0,
        medium: by_size["medium"]&.size || 0,
        small: by_size["small"]&.size || 0
      }
    end

    def csv_headers
      %w[reference name total_pages published_pages latest_published size]
    end

    private

    def from_hash(row)
      new(
        reference: row[:reference],
        name: row[:name],
        total_pages: row[:total_pages],
        published_pages: row[:published_pages],
        latest_published_at: row[:latest_published_at],
        size_category: row[:size_category]
      )
    end
  end
end
