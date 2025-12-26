# frozen_string_literal: true

require "ruby-progressbar"

module PageMigration
  module Services
    # Handles parallel or sequential execution of prompts
    class PromptRunner
      WORKER_COUNT = 5

      def initialize(processor, debug: false)
        @processor = processor
        @debug = debug
      end

      def run(prompts, summary, output_root, additional_instructions: nil)
        if @debug
          run_sequential(prompts, summary, output_root, additional_instructions)
        else
          run_parallel(prompts, summary, output_root, additional_instructions)
        end
      end

      private

      def run_sequential(prompts, summary, output_root, additional_instructions)
        puts "\nProcessing #{prompts.length} prompts sequentially (debug mode)..."
        prompts.each_with_index do |path, idx|
          puts "\n[#{idx + 1}/#{prompts.length}] Processing: #{File.basename(path)}"
          @processor.process(path, summary, output_root, additional_instructions: additional_instructions)
        end
      end

      def run_parallel(prompts, summary, output_root, additional_instructions)
        puts "\nProcessing #{prompts.length} prompts in parallel..."
        progress = ProgressBar.create(
          title: "Migration",
          total: prompts.length,
          format: "%t: %c/%C |%B| %p%% %e"
        )

        queue = Queue.new
        prompts.each { |p| queue << p }

        workers = WORKER_COUNT.times.map do
          Thread.new do
            while !queue.empty? && (path = safe_pop(queue))
              @processor.process(path, summary, output_root, additional_instructions: additional_instructions)
              progress.increment
            end
          end
        end
        workers.each(&:join)
      end

      def safe_pop(queue)
        queue.pop(true)
      rescue ThreadError
        nil
      end
    end
  end
end
