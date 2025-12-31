# frozen_string_literal: true

require_relative "streaming_io"

# Concern for jobs that execute commands with streaming output.
# Captures stdout/stderr and broadcasts to Turbo Streams in real-time.
#
# @example
#   class MyJob < ApplicationJob
#     include StreamingOutput
#
#     def perform(command_run_id)
#       command_run = CommandRun.find(command_run_id)
#       execute_with_streaming(command_run) do
#         puts "Working..."
#       end
#     end
#   end
#
module StreamingOutput
  extend ActiveSupport::Concern

  class InterruptedError < StandardError; end

  WEBSOCKET_INIT_DELAY = 0.5

  private

  def execute_with_streaming(command_run)
    start_command(command_run)
    capture_output(command_run) { yield }
    finalize_command(command_run)
  end

  def check_interrupted!(command_run)
    command_run.reload
    raise InterruptedError if command_run.interrupted?
  end

  # Command lifecycle

  def start_command(command_run)
    command_run.ensure_output_directory
    command_run.output = ""
    command_run.start!
    sleep(WEBSOCKET_INIT_DELAY)
    command_run.broadcast_update
  end

  def finalize_command(command_run)
    command_run.reload
    command_run.broadcast_update
  end

  # Output capture

  def capture_output(command_run)
    with_redirected_io(command_run) do |streaming_io|
      yield
      on_success(command_run, streaming_io)
    rescue InterruptedError
      on_interruption(command_run, streaming_io)
    rescue => e
      on_error(command_run, streaming_io, e)
    end
  end

  def with_redirected_io(command_run)
    original_stdout, original_stderr = $stdout, $stderr
    streaming_io = StreamingIO.new(command_run)
    $stdout = $stderr = streaming_io

    yield streaming_io
  ensure
    $stdout, $stderr = original_stdout, original_stderr
  end

  # Result handlers

  def on_success(command_run, streaming_io)
    streaming_io.stop!
    streaming_io.flush
    command_run.reload
    command_run.complete! unless command_run.interrupted?
  end

  def on_interruption(command_run, streaming_io)
    streaming_io.stop!
    command_run.append_output("\n⚠️ Command interrupted by user\n")
    streaming_io.flush
  end

  def on_error(command_run, streaming_io, error)
    streaming_io.stop!
    streaming_io.flush
    command_run.reload
    command_run.fail_with_error!(format_error(error)) unless command_run.interrupted?
  end

  def format_error(error)
    backtrace = error.backtrace&.first(10)&.join("\n")
    "#{error.class}: #{error.message}\n#{backtrace}"
  end
end
