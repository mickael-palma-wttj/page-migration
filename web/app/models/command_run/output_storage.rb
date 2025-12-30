# frozen_string_literal: true

class CommandRun
  module OutputStorage
    extend ActiveSupport::Concern

    COMMANDS_OUTPUT_DIR = Rails.root.join("storage", "commands")

    def output_directory
      COMMANDS_OUTPUT_DIR.join(command, id.to_s)
    end

    def export_data_directory
      output_directory.join("data")
    end

    def output_file_path
      output_directory.join("output.log")
    end

    def ensure_output_directory
      FileUtils.mkdir_p(output_directory)
      FileUtils.mkdir_p(export_data_directory)
    end

    def output
      return nil unless output_file_path.exist?
      output_file_path.read
    rescue Errno::ENOENT
      nil
    end

    def output=(content)
      ensure_output_directory
      output_file_path.write(content.to_s)
    end

    def append_output(text)
      ensure_output_directory
      output_file_path.open("a") { |f| f.write(text) }
    end

    private

    def cleanup_output_directory
      FileUtils.rm_rf(output_directory) if output_directory.exist?
    end
  end
end
