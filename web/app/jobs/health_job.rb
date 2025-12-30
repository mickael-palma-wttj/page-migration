# frozen_string_literal: true

class HealthJob < ApplicationJob
  include StreamingOutput

  queue_as :default

  def perform(command_run_id, _org_ref, _options = {})
    command_run = CommandRun.find(command_run_id)
    execute_with_streaming(command_run) do
      PageMigration::Commands::Health.new.call
    end
  end
end
