# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include ExportFinder
  include PaginationDefaults

  before_action :set_org_ref, only: [:show]

  def index
    @query = params[:q].to_s.strip
    @organizations = search_with_export_status if @query.present?
    @recent_orgs = recent_organizations unless @query.present?
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
    @current_tab = params[:tab]
    scope = CommandRun.where(org_ref: @org_ref)
    scope = scope.by_command(@current_tab) if @current_tab.present?
    @command_runs = scope.recent.limit(ORG_COMMANDS_LIMIT)
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

  def recent_organizations
    CommandRun.where.not(org_ref: [nil, ""])
      .select(:org_ref)
      .group(:org_ref)
      .order(Arel.sql("MAX(created_at) DESC"))
      .limit(RECENT_ORGS_LIMIT)
      .map do |cmd|
        org = OrganizationQuery.find_by_reference(cmd.org_ref)
        {
          reference: cmd.org_ref,
          name: org&.dig(:name) || cmd.org_ref,
          has_export: export_exists?(cmd.org_ref),
          last_command_at: CommandRun.where(org_ref: cmd.org_ref).maximum(:created_at)
        }
      end
  rescue => e
    Rails.logger.error("Failed to fetch recent organizations: #{e.message}")
    []
  end
end
