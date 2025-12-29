# frozen_string_literal: true

class DashboardController < ApplicationController
  include ExportFinder

  def index
    @recent_commands = CommandRun.recent.limit(10)
    @exports = list_exports(limit: 20).first(5)
  end
end
