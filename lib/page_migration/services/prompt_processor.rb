# frozen_string_literal: true

require 'json'
require 'fileutils'

module PageMigration
  module Services
    # Processes a single prompt file and generates the output using Dust API
    class PromptProcessor
      def initialize(client, _assistant_ids, runner, language: 'fr')
        @client = client
        @runner = runner
        @language = language
      end

      def process(prompt_path, content_summary, output_root, additional_instructions: nil)
        config = parse_prompt_file(prompt_path)
        prompt_name = File.basename(prompt_path, '.prompt.md')
        target_path = build_target_path(prompt_path, output_root, prompt_name)

        result = execute(config, content_summary, additional_instructions)
        return nil unless result

        save_result(target_path, result[:content], prompt_name)
        result[:content]
      end

      private

      MAX_FRAGMENT_SIZE = 500_000 # ~500KB to stay under 512KB limit

      def execute(config, summary, instructions)
        language_name = @language == 'fr' ? 'French' : 'English'
        user_content = "Role: #{config['role']}\n" \
                       "Task: #{config['task']}\n\n" \
                       "CRITICAL: ONLY use the information provided in the content fragments titled 'Organization Data'. DO NOT use external knowledge or hallucinate facts not present in the data.\n\n" \
                       "IMPORTANT: Generate all content in #{language_name} (#{@language}).\n\n" \
                       "Instructions:\n#{config['content']}"

        user_content += "\n\nGuidelines:\n#{instructions}" if instructions
        user_content += "\n\nOutput format: #{config['output_format'].to_json}"

        content_fragments = build_content_fragments(summary)
        @runner.run(user_content, content_fragments: content_fragments)
      end

      def build_content_fragments(content)
        return [{ title: "Organization Data", content: content }] if content.bytesize <= MAX_FRAGMENT_SIZE

        chunks = chunk_content(content, MAX_FRAGMENT_SIZE)
        chunks.each_with_index.map do |chunk, index|
          { title: "Organization Data (Part #{index + 1}/#{chunks.length})", content: chunk }
        end
      end

      def chunk_content(content, max_size)
        chunks = []
        current_chunk = ""

        content.each_line do |line|
          if (current_chunk.bytesize + line.bytesize) > max_size
            chunks << current_chunk unless current_chunk.empty?
            current_chunk = line
          else
            current_chunk += line
          end
        end
        chunks << current_chunk unless current_chunk.empty?
        chunks
      end

      def build_target_path(prompt_path, output_root, name)
        relative = prompt_path.sub(%r{^prompts/migration/}, '')
        subfolder = File.dirname(relative)
        target_dir = subfolder == '.' ? output_root : File.join(output_root, subfolder)
        FileUtils.mkdir_p(target_dir)
        File.join(target_dir, "#{name}.json")
      end

      def save_result(path, result, name)
        clean_result = extract_json(result)
        begin
          parsed = JSON.parse(clean_result)
          clean_result = JSON.pretty_generate(parsed)
        rescue JSON::ParserError
          # Silent failure for JSON parsing
        end

        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, clean_result)
        clean_result
      end

      def extract_json(text)
        # Try to find content between ```json and ``` or ```markdown and ```
        return Regexp.last_match(1).strip if text =~ /```(?:json|markdown)?\n?(.*?)\n?```/m

        # Find the first { and its matching } using brace counting
        first_brace = text.index('{')
        return text.strip unless first_brace

        count = 0
        text[first_brace..].each_char.with_index do |char, i|
          count += 1 if char == '{'
          count -= 1 if char == '}'
          return text[first_brace..(first_brace + i)].strip if count == 0
        end

        text.strip
      end

      def parse_prompt_file(path)
        content = File.read(path)
        # Remove markdown fences if present
        content = content.gsub(/^```prompt\n/, '').gsub(/\n```$/, '')
        JSON.parse(content)
      rescue JSON::ParserError => e
        raise "Failed to parse JSON in #{path}: #{e.message}"
      end
    end
  end
end
