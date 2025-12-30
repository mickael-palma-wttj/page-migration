# frozen_string_literal: true

class StatsController < ApplicationController
  include Pagy::Backend

  SIZES = %w[big medium small].freeze
  PER_PAGE = 50

  def index
    @size = params[:size] if SIZES.include?(params[:size])
    all_organizations = OrganizationQuery.stats(size: @size, limit: nil)
    @summary = calculate_summary(all_organizations)

    respond_to do |format|
      format.html do
        @pagy, @organizations = pagy_array(all_organizations, limit: PER_PAGE)
      end
      format.csv do
        @organizations = all_organizations
        send_csv
      end
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
