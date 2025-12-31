# frozen_string_literal: true

class StatsController < ApplicationController
  include StatsFilterable

  PER_PAGE = 20

  def index
    @size, @sort, @direction = stats_filter_params.values_at(:size, :sort, :direction)
    all_stats = OrganizationStat.all(**stats_filter_params)
    @summary = OrganizationStat.summary(all_stats)

    respond_to do |format|
      format.html do
        @pagy, stats = pagy_array(all_stats, limit: PER_PAGE)
        @stats = stats.map { |s| OrganizationStatPresenter.new(s) }
      end
      format.csv { send_csv(all_stats) }
    end
  rescue PG::Error => e
    flash.now[:alert] = "Database error: #{e.message}"
    @stats = []
    @summary = {total: 0, big: 0, medium: 0, small: 0}
  end

  private

  def send_csv(stats)
    csv_data = CSV.generate do |csv|
      csv << OrganizationStat.csv_headers
      stats.each { |stat| csv << stat.to_csv_row }
    end

    send_data csv_data,
      filename: "organization_stats_#{Date.current}.csv",
      type: "text/csv"
  end
end
