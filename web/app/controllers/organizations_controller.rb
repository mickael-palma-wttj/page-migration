# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include ExportFinder
  include PaginationDefaults

  before_action :set_org_ref, only: [:show]

  def index
    @query = params[:q].to_s.strip
    @organizations = search_with_export_status if @query.present?
  end

  def search
    query = params[:q].to_s.strip
    return render json: [] if query.blank?

    render json: OrganizationQuery.search(query, limit: ORG_SEARCH_JSON_LIMIT)
  rescue => e
    render json: {error: e.message}, status: :service_unavailable
  end

  def show
    @organization = OrganizationQuery.find_by_reference(@org_ref)
    @exports = list_exports(org_ref: @org_ref, include_files: true)
    @command_runs = CommandRun.where(org_ref: @org_ref).recent.limit(ORG_COMMANDS_LIMIT)
  end

  private

  def set_org_ref
    @org_ref = params[:id]
  end

  def search_with_export_status
    OrganizationQuery.search(@query, limit: ORG_SEARCH_LIMIT).map do |org|
      org.merge(has_export: export_exists?(org[:reference]))
    end
  rescue => e
    flash.now[:alert] = "Database connection error: #{e.message}"
    []
  end
end
