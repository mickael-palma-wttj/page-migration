# frozen_string_literal: true

class CommandRun
  # Handles Turbo Stream broadcasts for real-time UI updates.
  module Broadcasting
    extend ActiveSupport::Concern

    def broadcast_update
      Turbo::StreamsChannel.broadcast_update_to(
        stream_name,
        target: stream_name,
        html: render_partial
      )
    end

    private

    def stream_name
      "command_run_#{id}"
    end

    def render_partial
      ApplicationController.render(
        partial: "commands/command_run",
        locals: {command_run: self}
      )
    end
  end
end
