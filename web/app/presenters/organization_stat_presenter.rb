# frozen_string_literal: true

class OrganizationStatPresenter
  SIZE_BADGE_CLASSES = {
    "big" => "bg-red-100 text-red-700",
    "medium" => "bg-yellow-100 text-yellow-700",
    "small" => "bg-green-100 text-green-700"
  }.freeze

  SIZE_SUMMARY_COLORS = {
    "big" => "text-red-600",
    "medium" => "text-yellow-600",
    "small" => "text-green-600"
  }.freeze

  attr_reader :stat

  delegate :reference, :name, :total_pages, :published_pages,
    :latest_published_at, :size_category, :to_param, :to_csv_row,
    to: :stat

  def initialize(stat)
    @stat = stat
  end

  def truncated_name(length: 40)
    return name if name.length <= length
    "#{name[0..length - 4]}..."
  end

  def formatted_published_date
    return nil unless latest_published_at
    latest_published_at.to_s[0..9]
  end

  def size_badge_classes
    SIZE_BADGE_CLASSES.fetch(size_category, "bg-gray-100 text-gray-700")
  end

  def self.summary_color(size)
    SIZE_SUMMARY_COLORS.fetch(size, "text-wttj-black")
  end
end
