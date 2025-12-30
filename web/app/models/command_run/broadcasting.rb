# frozen_string_literal: true

class CommandRun
  module Broadcasting
    extend ActiveSupport::Concern

    def broadcast_update
      html = ApplicationController.render(
        partial: "commands/command_run",
        locals: {command_run: self}
      )

      Turbo::StreamsChannel.broadcast_update_to(
        "command_run_#{id}",
        target: "command_run_#{id}",
        html: html
      )
    end
  end
end
