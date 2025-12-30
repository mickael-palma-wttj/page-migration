# frozen_string_literal: true

# Custom IO class that streams command output in real-time to file and broadcasts via Turbo Streams.
# Implements the IO interface methods required by Ruby's $stdout/$stderr.
class StreamingIO
  BROADCAST_INTERVAL = 0.3

  def initialize(command_run)
    @command_run = command_run
    @buffer = StringIO.new
    @last_broadcast = Time.current
    @mutex = Mutex.new
    @suppress_broadcast = false
  end

  def suppress_broadcast!
    @suppress_broadcast = true
  end

  def write(str)
    return 0 if str.nil?

    str = str.to_s
    @mutex.synchronize do
      @buffer.write(str)
      @command_run.append_output(str)
      maybe_broadcast
    end
    str.bytesize
  end

  def <<(str)
    write(str)
    self
  end

  def puts(*args)
    args.empty? ? write("\n") : args.each { |arg| write("#{arg}\n") }
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
    @mutex.synchronize { broadcast_output }
    self
  end

  def sync
    true
  end

  def sync=(_value)
    # ignored, always sync
  end

  def tty?
    false
  end

  def isatty
    false
  end

  private

  def maybe_broadcast
    return unless Time.current - @last_broadcast >= BROADCAST_INTERVAL

    broadcast_output
    @last_broadcast = Time.current
  end

  def broadcast_output
    return if @suppress_broadcast

    output = @command_run.output || ""
    Turbo::StreamsChannel.broadcast_replace_to(
      "command_run_#{@command_run.id}",
      target: "output",
      html: output_html(output)
    )
  end

  def output_html(output)
    <<~HTML.squish
      <div id="output" data-auto-scroll-target="output"
           class="text-sm text-wttj-gray-light whitespace-pre-wrap max-h-96 overflow-y-auto">
        #{ERB::Util.html_escape(output.strip)}
      </div>
    HTML
  end
end
