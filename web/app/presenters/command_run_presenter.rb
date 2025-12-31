# frozen_string_literal: true

class CommandRunPresenter
  include TerminalOutput

  STATUS_COLORS = {
    "completed" => "green-500",
    "failed" => "red-500",
    "running" => "wttj-yellow",
    "interrupted" => "orange-500"
  }.freeze

  STATUS_TEXT_COLORS = {
    "completed" => "text-green-600",
    "failed" => "text-red-600",
    "running" => "text-wttj-yellow",
    "interrupted" => "text-orange-500"
  }.freeze

  attr_reader :command_run

  delegate :id, :command, :org_ref, :options, :status, :display_status,
    :formatted_duration, :created_at, :started_at, :completed_at, :error,
    :running?, :pending?, :completed?, :failed?, :interrupted?,
    :finished?, :interruptable?, :stale?,
    to: :command_run

  def output
    self.class.process_carriage_returns(command_run.output)
  end

  def initialize(command_run)
    @command_run = command_run
  end

  def status_color
    STATUS_COLORS.fetch(display_status, "wttj-gray-medium")
  end

  def status_text_color
    STATUS_TEXT_COLORS.fetch(display_status, "text-wttj-gray-dark")
  end

  def status_indicator_classes(size: :medium)
    size_class = case size
    when :small then "w-2 h-2"
    when :medium then "w-3 h-3"
    when :large then "w-4 h-4"
    else "w-3 h-3"
    end

    animation = running? ? " animate-pulse" : ""
    "#{size_class} bg-#{status_color} rounded-full#{animation}"
  end

  def formatted_options
    return [] unless options.present? && options.any?

    options.map do |key, value|
      formatted_value = value.is_a?(Array) ? value.join(", ") : value
      {key: key, value: formatted_value}
    end
  end

  def formatted_date
    created_at.strftime("%Y-%m-%d %H:%M")
  end

  def formatted_started_at
    started_at&.strftime("%Y-%m-%d %H:%M:%S") || "—"
  end

  def to_model
    command_run
  end

  def to_param
    command_run.to_param
  end

  def persisted?
    command_run.persisted?
  end
end
