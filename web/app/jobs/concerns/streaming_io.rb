# frozen_string_literal: true

# Custom IO class that streams command output to file and broadcasts via Turbo Streams.
# Uses a background thread to watch the output file and broadcast changes periodically.
#
# @example
#   streaming_io = StreamingIO.new(command_run)
#   $stdout = streaming_io
#   puts "Hello"  # Written to file and broadcast
#   streaming_io.stop!
#   streaming_io.flush
#
class StreamingIO
  include TerminalOutput

  BROADCAST_INTERVAL = 0.3
  THREAD_SHUTDOWN_TIMEOUT = 2

  def initialize(command_run)
    @command_run = command_run
    @stop_requested = false
    @last_size = 0
    start_file_watcher
  end

  # Lifecycle

  def stop!
    @stop_requested = true
    @watcher_thread&.join(THREAD_SHUTDOWN_TIMEOUT)
  end

  def flush
    broadcast_output
    self
  end

  # IO interface - write methods

  def write(str)
    return 0 if str.nil?

    str = str.to_s
    @command_run.append_output(str)
    str.bytesize
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

  # IO interface - sync and tty

  def sync
    true
  end

  def sync=(_value)
    # Always sync, ignored
  end

  def tty?
    true
  end

  def isatty
    true
  end

  # Required by ruby-progressbar to determine terminal width
  def winsize
    [24, 120] # rows, columns
  end

  private

  def start_file_watcher
    @watcher_thread = Thread.new { watch_file }
  end

  def watch_file
    until @stop_requested
      broadcast_if_changed
      sleep BROADCAST_INTERVAL
    end
  rescue => e
    Rails.logger.error "[StreamingIO] Watcher thread error: #{e.message}"
  end

  def broadcast_if_changed
    return unless output_file_exists?

    current_size = @command_run.output_file_path.size
    return if current_size == @last_size

    @last_size = current_size
    broadcast_output
  end

  def output_file_exists?
    @command_run.output_file_path.exist?
  end

  def broadcast_output
    output = @command_run.output
    return if output.blank?

    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name,
      target: "output",
      html: render_output(output)
    )
  end

  def stream_name
    "command_run_#{@command_run.id}"
  end

  def render_output(output)
    processed = self.class.process_carriage_returns(output.strip)
    escaped = ERB::Util.html_escape(processed)
    %(<div id="output" data-auto-scroll-target="output" class="text-sm text-wttj-gray-light whitespace-pre-wrap max-h-96 overflow-y-auto">#{escaped}</div>)
  end
end
