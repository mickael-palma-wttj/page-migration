# frozen_string_literal: true

# Non-ActiveRecord model for organization statistics
# Wraps OrganizationQuery.stats and provides domain logic
class OrganizationStat
  SIZES = %w[big medium small].freeze
  SIZE_THRESHOLDS = {big: 10, medium: 2}.freeze
  SORTABLE_COLUMNS = %w[reference name total_pages published_pages latest_published_at size_category].freeze
  DEFAULT_SORT = "total_pages"
  DEFAULT_DIRECTION = "desc"

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

  SIZES.each do |size|
    define_method("#{size}?") { size_category == size }
  end

  def to_param
    reference
  end

  def to_csv_row
    [reference, name, total_pages, published_pages, latest_published_at, size_category]
  end

  class << self
    def all(size: nil, sort: DEFAULT_SORT, direction: DEFAULT_DIRECTION)
      stats = OrganizationQuery.stats(size: size).map { |row| from_hash(row) }
      sort_stats(stats, sort, direction)
    end

    def valid_sort?(column)
      SORTABLE_COLUMNS.include?(column)
    end

    def valid_direction?(dir)
      %w[asc desc].include?(dir)
    end

    def summary(stats)
      by_size = stats.group_by(&:size_category)
      SIZES.each_with_object({total: stats.size}) do |size, hash|
        hash[size.to_sym] = by_size[size]&.size || 0
      end
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

    def sort_stats(stats, column, direction)
      sorted = stats.sort_by { |stat| stat.public_send(column) || "" }
      descending?(direction) ? sorted.reverse : sorted
    end

    def descending?(direction)
      direction == "desc"
    end
  end
end
