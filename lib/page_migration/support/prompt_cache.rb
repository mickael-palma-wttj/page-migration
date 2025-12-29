# frozen_string_literal: true

require "digest"
require "json"
require "fileutils"

module PageMigration
  module Support
    # Caches prompt outputs based on content fingerprints to avoid duplicate API calls
    class PromptCache
      CACHE_DIR = ".cache"
      CACHE_VERSION = "v1"

      def initialize(output_root, enabled: true)
        @output_root = output_root
        @enabled = enabled
        @cache_dir = File.join(output_root, CACHE_DIR)
        @hits = 0
        @misses = 0
      end

      attr_reader :hits, :misses

      def enabled?
        @enabled
      end

      # Compute fingerprint from prompt content and input summary
      def fingerprint(prompt_content, input_summary)
        data = "#{CACHE_VERSION}:#{prompt_content}:#{input_summary}"
        Digest::SHA256.hexdigest(data)
      end

      # Check if cached result exists for fingerprint
      def cached?(fingerprint)
        return false unless @enabled

        File.exist?(cache_path(fingerprint))
      end

      # Get cached result for fingerprint
      def get(fingerprint)
        return nil unless @enabled

        path = cache_path(fingerprint)
        return nil unless File.exist?(path)

        @hits += 1
        data = JSON.parse(File.read(path), symbolize_names: true)
        data[:content]
      rescue JSON::ParserError
        nil
      end

      # Store result for fingerprint
      def set(fingerprint, content, metadata = {})
        return unless @enabled

        @misses += 1
        FileUtils.mkdir_p(@cache_dir)

        data = {
          fingerprint: fingerprint,
          content: content,
          cached_at: Time.now.iso8601,
          **metadata
        }

        File.write(cache_path(fingerprint), JSON.pretty_generate(data))
      end

      # Get or compute result using block
      def fetch(prompt_content, input_summary, metadata = {})
        fp = fingerprint(prompt_content, input_summary)

        if (cached = get(fp))
          return cached
        end

        result = yield
        set(fp, result, metadata) if result
        result
      end

      def stats
        {hits: @hits, misses: @misses, hit_rate: hit_rate}
      end

      def hit_rate
        total = @hits + @misses
        return 0.0 if total.zero?

        (@hits.to_f / total * 100).round(1)
      end

      def clear!
        FileUtils.rm_rf(@cache_dir) if Dir.exist?(@cache_dir)
        @hits = 0
        @misses = 0
      end

      private

      def cache_path(fingerprint)
        File.join(@cache_dir, "#{fingerprint[0..7]}.json")
      end
    end
  end
end
