# frozen_string_literal: true

class CommandRun
  module Broadcasting
    extend ActiveSupport::Concern

    def broadcast_update
      stream_name = "command_run_#{id}"
      target_id = "command_run_#{id}"

      html = ApplicationController.render(
        partial: "commands/command_run",
        locals: {command_run: self}
      )

      Rails.logger.info "[Broadcast] Sending update to stream: #{stream_name}, target: #{target_id}"

      Turbo::StreamsChannel.broadcast_update_to(
        stream_name,
        target: target_id,
        html: html
      )
    end
  end
end
