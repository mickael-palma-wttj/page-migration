# frozen_string_literal: true

# Controller concern that delegates to ExportService
# Provides convenient controller-level methods for export operations
module ExportFinder
  extend ActiveSupport::Concern

  private

  def find_export_path(id)
    ExportService.find_path(id)
  end

  def extract_org_ref(id)
    ExportService.extract_org_ref(id)
  end

  def find_command_run_for_export(id)
    ExportService.find_command_run(id)
  end

  def list_exports(scope: CommandRun.completed, limit: nil, org_ref: nil, include_files: false)
    ExportService.list(scope: scope, limit: limit, org_ref: org_ref, include_files: include_files)
  end

  def export_exists?(org_ref)
    ExportService.exists?(org_ref)
  end
end
