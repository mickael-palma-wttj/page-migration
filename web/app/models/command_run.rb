# frozen_string_literal: true

class CommandRun < ApplicationRecord
  STATUSES = %w[pending running completed failed].freeze
  COMMANDS = %w[extract export migrate tree health].freeze
  STALE_THRESHOLD = 5.minutes
  COMMANDS_OUTPUT_DIR = Rails.root.join("storage", "commands")

  validates :command, presence: true, inclusion: {in: COMMANDS}
  validates :status, presence: true, inclusion: {in: STATUSES}

  after_destroy :cleanup_output_directory

  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :running, -> { where(status: "running") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :stale, -> { where(status: %w[pending running]).where("updated_at < ?", STALE_THRESHOLD.ago) }

  def pending?
    status == "pending"
  end

  def running?
    status == "running"
  end

  def stale?
    (pending? || running?) && updated_at < STALE_THRESHOLD.ago
  end

  def display_status
    return "interrupted" if stale?
    status
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def finished?
    completed? || failed?
  end

  def duration
    return nil unless started_at

    end_time = completed_at || Time.current
    (end_time - started_at).round(2)
  end

  # File-based output storage
  def output_directory
    COMMANDS_OUTPUT_DIR.join(command, id.to_s)
  end

  # Directory where CLI commands store export data (replaces global tmp/)
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
