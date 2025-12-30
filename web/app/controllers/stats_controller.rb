# frozen_string_literal: true

class StatsController < ApplicationController
  SIZES = %w[big medium small].freeze
  DEFAULT_LIMIT = 50

  def index
    @size = params[:size] if SIZES.include?(params[:size])
    @limit = (params[:limit] || DEFAULT_LIMIT).to_i.clamp(1, 500)
    @organizations = OrganizationQuery.stats(size: @size, limit: @limit)
    @summary = calculate_summary(@organizations)

    respond_to do |format|
      format.html
      format.csv { send_csv }
    end
  rescue => e
    flash.now[:alert] = "Database error: #{e.message}"
    @organizations = []
    @summary = {total: 0, big: 0, medium: 0, small: 0}
  end

  private

  def calculate_summary(orgs)
    by_size = orgs.group_by { |o| o[:size_category] }
    {
      total: orgs.size,
      big: by_size["big"]&.size || 0,
      medium: by_size["medium"]&.size || 0,
      small: by_size["small"]&.size || 0
    }
  end

  def send_csv
    csv_data = CSV.generate do |csv|
      csv << %w[reference name total_pages published_pages latest_published size]
      @organizations.each do |org|
        csv << [
          org[:reference],
          org[:name],
          org[:total_pages],
          org[:published_pages],
          org[:latest_published_at],
          org[:size_category]
        ]
      end
    end

    filename = "organization_stats_#{Date.current}.csv"
    send_data csv_data, filename: filename, type: "text/csv"
  end
end
