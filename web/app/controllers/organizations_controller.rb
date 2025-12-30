# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include PaginationDefaults

  before_action :set_org_ref, only: [:show]

  def index
    @query = params[:q].to_s.strip
    if @query.present?
      @organizations = Organization.search(@query, limit: ORG_SEARCH_LIMIT, include_export_status: true)
    else
      @recent_orgs = Organization.recent_from_commands(limit: RECENT_ORGS_LIMIT)
    end
  rescue => e
    flash.now[:alert] = "Database connection error: #{e.message}"
    @organizations = []
  end

  def search
    query = params[:q].to_s.strip
    return render json: [] if query.blank?

    render json: OrganizationQuery.search(query, limit: ORG_SEARCH_JSON_LIMIT)
  rescue => e
    render json: {error: e.message}, status: :service_unavailable
  end

  def show
    @organization = Organization.find_by_reference(@org_ref)
    @current_tab = params[:tab]
    scope = CommandRun.where(org_ref: @org_ref)
    scope = scope.by_command(@current_tab) if @current_tab.present?
    @command_runs = scope.recent.limit(ORG_COMMANDS_LIMIT)
  end

  private

  def set_org_ref
    @org_ref = params[:id]
  end
end
