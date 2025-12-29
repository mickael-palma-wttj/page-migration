# frozen_string_literal: true

class CommandRun < ApplicationRecord
  STATUSES = %w[pending running completed failed interrupted].freeze
  COMMANDS = %w[extract export migrate tree health].freeze
  STALE_THRESHOLD = 5.minutes
  COMMANDS_OUTPUT_DIR = Rails.root.join("storage", "commands")

  # Validations
  validates :command, presence: true, inclusion: {in: COMMANDS}
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :org_ref, length: {maximum: 50}, allow_blank: true

  # Callbacks
  after_destroy :cleanup_output_directory

  # Scopes - status filters
  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :running, -> { where(status: "running") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :finished, -> { where(status: %w[completed failed interrupted]) }
  scope :interrupted, -> { where(status: "interrupted") }
  scope :stale, -> { where(status: %w[pending running]).where("updated_at < ?", STALE_THRESHOLD.ago) }

  # Scopes - command filters
  scope :by_command, ->(cmd) { where(command: cmd) }
  scope :by_org_ref, ->(org_ref) { where(org_ref: org_ref) }

  # Scopes - time filters
  scope :created_today, -> { where(created_at: Time.current.beginning_of_day..) }
  scope :created_this_week, -> { where(created_at: 1.week.ago..) }

  # Status predicates
  def pending?
    status == "pending"
  end

  def running?
    status == "running"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def interrupted?
    status == "interrupted"
  end

  def finished?
    completed? || failed? || interrupted?
  end

  def interruptable?
    pending? || running?
  end

  def interrupt!
    return unless interruptable?

    update!(
      status: "interrupted",
      completed_at: Time.current,
      error: "Interrupted by user"
    )
    broadcast_update
  end

  def stale?
    (pending? || running?) && updated_at < STALE_THRESHOLD.ago
  end

  def display_status
    return "interrupted" if stale? && !interrupted?
    status
  end

  def broadcast_update
    # Use ApplicationController.render to get full helper context
    html = ApplicationController.render(
      partial: "commands/command_run",
      locals: {command_run: self}
    )

    # Use update action instead of replace to ensure full DOM replacement
    Turbo::StreamsChannel.broadcast_update_to(
      "command_run_#{id}",
      target: "command_run_#{id}",
      html: html
    )
  end

  # Duration calculation
  def duration
    return nil unless started_at

    end_time = completed_at || Time.current
    (end_time - started_at).round(2)
  end

  def formatted_duration
    return nil unless duration

    total_seconds = duration.to_i
    return "#{duration.round(1)}s" if total_seconds < 60

    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60

    if hours > 0
      "#{hours}h #{minutes}m #{seconds}s"
    else
      "#{minutes}m #{seconds}s"
    end
  end

  # File-based output storage
  def output_directory
    COMMANDS_OUTPUT_DIR.join(command, id.to_s)
  end

  def export_data_directory
    output_directory.join("data")
  end

  def output_file_path
    output_directory.join("output.log")
  end

  def ensure_output_directory
    FileUtils.mkdir_p(output_directory)
    FileUtils.mkdir_p(export_data_directory)
  end

  def output
    return nil unless output_file_path.exist?
    output_file_path.read
  rescue Errno::ENOENT
    nil
  end

  def output=(content)
    ensure_output_directory
    output_file_path.write(content.to_s)
  end

  def append_output(text)
    ensure_output_directory
    output_file_path.open("a") { |f| f.write(text) }
  end

  private

  def cleanup_output_directory
    FileUtils.rm_rf(output_directory) if output_directory.exist?
  end
end
