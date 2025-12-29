# frozen_string_literal: true

class DashboardController < ApplicationController
  include ExportFinder
  include PaginationDefaults

  def index
    @recent_commands = CommandRun.recent.limit(DASHBOARD_COMMANDS_LIMIT)
    @exports = list_exports(limit: EXPORTS_QUERY_LIMIT).first(DASHBOARD_EXPORTS_LIMIT)
  end
end
