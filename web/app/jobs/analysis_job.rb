# frozen_string_literal: true

class AnalysisJob < ApplicationJob
  include StreamingOutput

  queue_as :default

  def perform(command_run_id, org_ref, options = {})
    command_run = CommandRun.find(command_run_id)
    execute_with_streaming(command_run) do
      PageMigration::Config.with_output_root(command_run.export_data_directory.to_s) do
        PageMigration::Commands::Migrate.new(
          org_ref,
          language: options["language"] || "fr",
          analysis: true
        ).call
      end
    end
  end
end
