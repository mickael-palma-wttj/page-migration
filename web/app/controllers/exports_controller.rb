# frozen_string_literal: true

class ExportsController < ApplicationController
  include ExportFinder

  before_action :set_export, only: [:show, :file]

  def index
    @exports = list_exports
  end

  def show
    @files = ExportService.list_files(@export_path)
    @org_ref = extract_org_ref(params[:id])
    @command_run = find_command_run_for_export(params[:id])
  end

  def file
    full_path = File.join(@export_path, params[:path])

    unless valid_file_path?(full_path)
      return redirect_to export_path(params[:id]), alert: "File not found"
    end

    @file_name = File.basename(full_path)
    @file_content = File.read(full_path)
    @file_type = ExportService.detect_file_type(@file_name)
    @highlighted_content = ExportService.highlight(@file_content, @file_type)

    render "file", formats: [:html]
  end

  private

  def set_export
    @export_path = find_export_path(params[:id])
    redirect_to exports_path, alert: "Export not found" unless @export_path
  end

  def valid_file_path?(full_path)
    File.exist?(full_path) && full_path.start_with?(@export_path)
  end
end
