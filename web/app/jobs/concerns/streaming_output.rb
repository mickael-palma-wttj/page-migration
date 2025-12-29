# frozen_string_literal: true

module StreamingOutput
  extend ActiveSupport::Concern

  private

  def execute_with_streaming(command_run)
    command_run.ensure_output_directory
    command_run.output = ""
    command_run.update!(status: "running", started_at: Time.current)
    broadcast_update(command_run)

    original_stdout = $stdout
    original_stderr = $stderr

    # Create a custom IO that captures and streams output to file
    streaming_io = StreamingIO.new(command_run)
    $stdout = streaming_io
    $stderr = streaming_io

    begin
      yield
      streaming_io.flush # Final flush before completing
      command_run.update!(status: "completed", completed_at: Time.current)
    rescue => e
      streaming_io.flush
      command_run.update!(
        status: "failed",
        completed_at: Time.current,
        error: "#{e.class}: #{e.message}\n#{e.backtrace&.first(10)&.join("\n")}"
      )
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end

    broadcast_update(command_run)
  end

  def broadcast_update(command_run)
    Turbo::StreamsChannel.broadcast_replace_to(
      "command_run_#{command_run.id}",
      target: "command_run_#{command_run.id}",
      partial: "commands/command_run",
      locals: {command_run: command_run}
    )
  end

  # Custom IO class that streams output in real-time to file
  class StreamingIO
    BROADCAST_INTERVAL = 0.3 # seconds - faster updates

    def initialize(command_run)
      @command_run = command_run
      @buffer = StringIO.new
      @last_broadcast = Time.current
      @mutex = Mutex.new
    end

    def write(str)
      return 0 if str.nil?
      str = str.to_s
      @mutex.synchronize do
        @buffer.write(str)
        # Append to file immediately
        @command_run.append_output(str)

        # Broadcast periodically to avoid overwhelming the client
        if Time.current - @last_broadcast >= BROADCAST_INTERVAL
          broadcast_current_output
          @last_broadcast = Time.current
        end
      end
      str.bytesize # Return bytes written (required by IO interface)
    end

    def <<(str)
      write(str)
      self
    end

    def puts(*args)
      if args.empty?
        write("\n")
      else
        args.each { |arg| write("#{arg}\n") }
      end
      nil
    end

    def print(*args)
      args.each { |arg| write(arg.to_s) }
      nil
    end

    def printf(format, *args)
      write(format % args)
      nil
    end

    def flush
      @mutex.synchronize do
        broadcast_current_output
      end
      self
    end

    def sync
      true
    end

    def sync=(value)
      # ignore, always sync
    end

    def tty?
      false
    end

    def isatty
      false
    end

    private

    def broadcast_current_output
      output = @command_run.output || ""
      # Only update the output div, not the entire partial (to avoid huge payloads)
      Turbo::StreamsChannel.broadcast_replace_to(
        "command_run_#{@command_run.id}",
        target: "output",
        html: "<div id=\"output\" data-auto-scroll-target=\"output\" class=\"text-sm text-wttj-gray-light whitespace-pre-wrap max-h-96 overflow-y-auto\">#{ERB::Util.html_escape(output.strip)}</div>"
      )
    end
  end
end
