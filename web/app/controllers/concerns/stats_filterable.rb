# frozen_string_literal: true

# Controller concern for sanitizing stats filter parameters
module StatsFilterable
  extend ActiveSupport::Concern

  private

  def sanitized_size
    params[:size] if OrganizationStat::SIZES.include?(params[:size])
  end

  def sanitized_sort
    OrganizationStat.valid_sort?(params[:sort]) ? params[:sort] : OrganizationStat::DEFAULT_SORT
  end

  def sanitized_direction
    OrganizationStat.valid_direction?(params[:direction]) ? params[:direction] : OrganizationStat::DEFAULT_DIRECTION
  end

  def stats_filter_params
    @stats_filter_params ||= {size: sanitized_size, sort: sanitized_sort, direction: sanitized_direction}
  end
end
