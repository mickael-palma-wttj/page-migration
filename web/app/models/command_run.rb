# frozen_string_literal: true

class CommandRun < ApplicationRecord
  include CommandRun::OutputStorage
  include CommandRun::Broadcasting

  STATUSES = %w[pending running completed failed interrupted].freeze
  COMMANDS = %w[extract export migrate analysis tree health].freeze
  STALE_THRESHOLD = 5.minutes

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

  # Status predicates using inquiry
  STATUSES.each do |status_name|
    define_method(:"#{status_name}?") { status == status_name }
  end

  def finished?
    completed? || failed? || interrupted?
  end

  def interruptable?
    pending? || running?
  end

  def stale?
    interruptable? && updated_at < STALE_THRESHOLD.ago
  end

  def display_status
    stale? ? "interrupted" : status
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

    hours, remainder = total_seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)

    if hours > 0
      "#{hours}h #{minutes}m #{seconds}s"
    else
      "#{minutes}m #{seconds}s"
    end
  end
end
