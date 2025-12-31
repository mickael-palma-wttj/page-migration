# frozen_string_literal: true

class CommandsController < ApplicationController
  include PaginationDefaults

  COMMAND_JOBS = {
    "extract" => ExtractJob,
    "export" => ExportJob,
    "migrate" => MigrateJob,
    "analysis" => AnalysisJob,
    "tree" => TreeJob,
    "health" => HealthJob
  }.freeze

  COMMANDS_REQUIRING_ORG = %w[extract export migrate analysis tree].freeze

  before_action :set_command_run, only: [:show, :destroy, :interrupt, :download]
  before_action :validate_org_ref, only: [:create]

  def index
    @current_tab = params[:tab]
    scope = @current_tab.present? ? CommandRun.by_command(@current_tab).recent : CommandRun.recent
    @pagy, @command_runs = pagy(scope, limit: COMMANDS_PER_PAGE)
  end

  def new
    @org_ref = params[:org_ref]
    @command = params[:command] || "extract"
  end

  def create
    @command_run = CommandRun.create!(
      command: command_params[:command],
      org_ref: command_params[:org_ref],
      options: build_options,
      status: "pending"
    )

    job_class = COMMAND_JOBS.fetch(@command_run.command) do
      raise ArgumentError, "Unknown command: #{@command_run.command}"
    end
    job_class.perform_later(@command_run.id, @command_run.org_ref, @command_run.options)

    redirect_to command_path(@command_run), notice: "Command queued for execution"
  end

  def show
  end

  def destroy
    @command_run.destroy
    redirect_to commands_path, notice: "Command run deleted"
  end

  def interrupt
    if @command_run.interruptable?
      @command_run.interrupt!
      redirect_to command_path(@command_run), notice: "Command interrupted"
    else
      redirect_to command_path(@command_run), alert: "Command is not running"
    end
  end

  def download
    unless @command_run.output_directory.exist?
      redirect_to command_path(@command_run), alert: "No output files available"
      return
    end

    zip_data = ZipService.create_from_directory(@command_run.output_directory)
    filename = "#{@command_run.command}_#{@command_run.org_ref || @command_run.id}_#{@command_run.created_at.strftime("%Y%m%d_%H%M%S")}.zip"

    send_data zip_data, filename: filename, type: "application/zip", disposition: "attachment"
  end

  private

  def set_command_run
    @command_run = CommandRun.find(params[:id])
  end

  def validate_org_ref
    command = command_params[:command]
    org_ref = command_params[:org_ref]

    if COMMANDS_REQUIRING_ORG.include?(command) && org_ref.blank?
      redirect_to new_command_path(command: command), alert: "Organization is required for #{command} command"
    end
  end

  def command_params
    @command_params ||= params.permit(:command, :org_ref, :format_option, :language, :languages, :agent_id, :authenticity_token, :commit)
  end

  def build_options
    {}.tap do |opts|
      opts[:format] = command_params[:format_option] if command_params[:format_option].present?
      opts[:language] = command_params[:language] if command_params[:language].present?
      opts[:languages] = command_params[:languages].split(",").map(&:strip) if command_params[:languages].present?
      opts[:agent_id] = command_params[:agent_id] if command_params[:agent_id].present?
    end
  end
end
