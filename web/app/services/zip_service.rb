# frozen_string_literal: true

require "zip"

class ZipService
  class << self
    def create_from_directory(directory)
      buffer = Zip::OutputStream.write_buffer do |zip|
        base_path = directory.to_s

        Dir.glob(File.join(base_path, "**", "*")).each do |file_path|
          next if File.directory?(file_path)

          relative_path = file_path.sub("#{base_path}/", "")
          zip.put_next_entry(relative_path)
          zip.write(File.read(file_path))
        end
      end

      buffer.string
    end
  end
end
