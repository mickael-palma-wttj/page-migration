# frozen_string_literal: true

class CommandsController < ApplicationController
  include PaginationDefaults

  before_action :set_command_run, only: [:show, :destroy]

  def index
    @pagy, @command_runs = pagy(CommandRun.recent, limit: COMMANDS_PER_PAGE)
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

    job_class = job_for_command(@command_run.command)
    job_class.perform_later(@command_run.id, @command_run.org_ref, @command_run.options)

    redirect_to command_path(@command_run), notice: "Command queued for execution"
  end

  def show
  end

  def destroy
    @command_run.destroy
    redirect_to commands_path, notice: "Command run deleted"
  end

  private

  def set_command_run
    @command_run = CommandRun.find(params[:id])
  end

  def command_params
    @command_params ||= params.permit(:command, :org_ref, :format_option, :language, :languages)
  end

  def build_options
    options = {}
    options[:format] = command_params[:format_option] if command_params[:format_option].present?
    options[:language] = command_params[:language] if command_params[:language].present?
    options[:languages] = command_params[:languages].split(",").map(&:strip) if command_params[:languages].present?
    options
  end

  def job_for_command(command)
    case command
    when "extract" then ExtractJob
    when "export" then ExportJob
    when "migrate" then MigrateJob
    when "tree" then TreeJob
    when "health" then HealthJob
    else
      raise ArgumentError, "Unknown command: #{command}"
    end
  end
end
