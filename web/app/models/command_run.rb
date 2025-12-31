# frozen_string_literal: true

class CommandRun < ApplicationRecord
  include AASM
  include CommandRun::OutputStorage
  include CommandRun::Broadcasting

  COMMANDS = %w[extract export migrate analysis tree health].freeze
  STALE_THRESHOLD = 5.minutes

  # Validations
  validates :command, presence: true, inclusion: {in: COMMANDS}
  validates :org_ref, length: {maximum: 50}, allow_blank: true

  # Callbacks
  after_destroy :cleanup_output_directory

  # State machine
  aasm column: :status do
    state :pending, initial: true
    state :running
    state :completed
    state :failed
    state :interrupted

    event :start do
      transitions from: :pending, to: :running
      after { update!(started_at: Time.current) }
    end

    event :complete do
      transitions from: :running, to: :completed
      after { update!(completed_at: Time.current) }
    end

    event :fail, after: :record_failure do
      transitions from: :running, to: :failed
    end

    event :interrupt do
      transitions from: [:pending, :running], to: :interrupted
      after { update!(completed_at: Time.current, error: "Interrupted by user") }
    end
  end

  # Scopes - status filters
  scope :recent, -> { order(created_at: :desc) }
  scope :finished, -> { where(status: %w[completed failed interrupted]) }
  scope :stale, -> { where(status: %w[pending running]).where("updated_at < ?", STALE_THRESHOLD.ago) }

  # Scopes - command filters
  scope :by_command, ->(cmd) { where(command: cmd) }
  scope :by_org_ref, ->(org_ref) { where(org_ref: org_ref) }

  # Scopes - time filters
  scope :created_today, -> { where(created_at: Time.current.beginning_of_day..) }
  scope :created_this_week, -> { where(created_at: 1.week.ago..) }

  def finished?
    completed? || failed? || interrupted?
  end

  def interruptable?
    may_interrupt?
  end

  def stale?
    interruptable? && updated_at < STALE_THRESHOLD.ago
  end

  def display_status
    stale? ? "interrupted" : status
  end

  def interrupt!
    return unless may_interrupt?

    interrupt
    broadcast_update
  end

  def fail_with_error!(error)
    @failure_error = error
    fail!
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

  private

  def record_failure
    update!(completed_at: Time.current, error: @failure_error)
  end
end
