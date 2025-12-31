# frozen_string_literal: true

require_relative "streaming_io"

module StreamingOutput
  extend ActiveSupport::Concern

  class InterruptedError < StandardError; end

  private

  def execute_with_streaming(command_run)
    setup_command(command_run)
    streaming_io = capture_output(command_run) { yield }
    finalize_command(command_run, streaming_io)
  end

  def check_interrupted!(command_run)
    command_run.reload
    raise InterruptedError if command_run.interrupted?
  end

  def broadcast_update(command_run)
    command_run.broadcast_update
  end

  def setup_command(command_run)
    command_run.ensure_output_directory
    command_run.output = ""
    command_run.start!
    sleep(0.5) # Allow WebSocket subscription to establish after page load
    broadcast_update(command_run)
  end

  def capture_output(command_run)
    original_stdout, original_stderr = $stdout, $stderr
    streaming_io = StreamingIO.new(command_run)
    $stdout = $stderr = streaming_io

    begin
      yield
      handle_success(command_run, streaming_io)
    rescue InterruptedError
      handle_interruption(command_run, streaming_io)
    rescue => e
      handle_error(command_run, streaming_io, e)
    ensure
      $stdout, $stderr = original_stdout, original_stderr
    end

    streaming_io
  end

  def handle_success(command_run, streaming_io)
    streaming_io.suppress_broadcast!
    streaming_io.flush
    command_run.reload
    return if command_run.interrupted?

    command_run.complete!
  end

  def handle_interruption(command_run, streaming_io)
    streaming_io.suppress_broadcast!
    streaming_io.flush
    command_run.append_output("\n⚠️ Command interrupted by user\n")
  end

  def handle_error(command_run, streaming_io, error)
    streaming_io.suppress_broadcast!
    streaming_io.flush
    command_run.reload
    return if command_run.interrupted?

    command_run.fail_with_error!(format_error(error))
  end

  def format_error(error)
    "#{error.class}: #{error.message}\n#{error.backtrace&.first(10)&.join("\n")}"
  end

  def finalize_command(command_run, _streaming_io)
    command_run.reload
    broadcast_update(command_run)
  end
end
