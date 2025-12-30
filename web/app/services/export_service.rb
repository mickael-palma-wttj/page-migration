# frozen_string_literal: true

class ExportService
  FILE_TYPES = {
    ".json" => :json,
    ".md" => :markdown,
    ".markdown" => :markdown
  }.freeze

  LEXERS = {
    json: Rouge::Lexers::JSON,
    markdown: Rouge::Lexers::Markdown,
    text: Rouge::Lexers::PlainText
  }.freeze

  class << self
    def find_path(id)
      if id.include?(":")
        cmd_id, export_name = id.split(":", 2)
        cmd = CommandRun.find_by(id: cmd_id)
        return nil unless cmd

        path = File.join(cmd.export_data_directory, export_name)
        return path if File.directory?(path)
      end

      legacy_path = File.join(PageMigration::Config::DEFAULT_OUTPUT_ROOT, id)
      legacy_path if File.directory?(legacy_path)
    end

    def extract_org_ref(id)
      _, export_name = id.include?(":") ? id.split(":", 2) : [nil, id]
      export_name.split("_").first
    end

    def find_command_run(id)
      return nil unless id.include?(":")

      cmd_id, _ = id.split(":", 2)
      CommandRun.find_by(id: cmd_id)
    end

    def list(scope: CommandRun.completed, limit: nil, org_ref: nil, include_files: false)
      exports = []
      query = scope.order(created_at: :desc)
      query = query.limit(limit) if limit

      pattern = org_ref ? "#{org_ref}_*" : "*_*"

      query.find_each do |cmd|
        data_dir = cmd.export_data_directory
        next unless data_dir.exist?

        Dir.glob(File.join(data_dir, pattern)).select { |d| File.directory?(d) }.each do |dir|
          exports << build_entry(cmd, dir, include_files: include_files)
        end
      end

      exports.sort_by { |e| e[:modified_at] }.reverse
    end

    def exists?(org_ref)
      CommandRun.completed.find_each do |cmd|
        data_dir = cmd.export_data_directory
        next unless data_dir.exist?
        return true if Dir.glob(File.join(data_dir, "#{org_ref}_*")).any?
      end
      false
    end

    def list_files(export_path)
      Dir.glob(File.join(export_path, "**/*"))
        .select { |f| File.file?(f) }
        .map { |file| build_file_info(file, export_path) }
        .sort_by { |f| f[:path] }
    end

    def find_export_id_for_org(org_ref, command_run: nil)
      export_dir = find_latest_export_dir(org_ref, command_run: command_run)
      return nil unless export_dir

      folder_name = File.basename(export_dir)
      command_run ? "#{command_run.id}:#{folder_name}" : folder_name
    end

    def find_export_files_for_org(org_ref, command_run: nil)
      export_dir = find_latest_export_dir(org_ref, command_run: command_run)
      return [] unless export_dir

      folder_name = File.basename(export_dir)
      export_id = command_run ? "#{command_run.id}:#{folder_name}" : folder_name

      Dir.glob(File.join(export_dir, "**/*"))
        .select { |f| File.file?(f) }
        .map { |file| build_file_info(file, export_dir).merge(export_id: export_id) }
        .sort_by { |f| f[:path] }
    end

    def detect_file_type(filename)
      FILE_TYPES.fetch(File.extname(filename).downcase, :text)
    end

    def highlight(content, type)
      lexer = LEXERS.fetch(type, LEXERS[:text]).new
      Rouge::Formatters::HTML.new.format(lexer.lex(content))
    end

    private

    def find_latest_export_dir(org_ref, command_run: nil)
      output_dir = command_run&.export_data_directory&.to_s || PageMigration::Config::DEFAULT_OUTPUT_ROOT
      return nil unless Dir.exist?(output_dir)

      Dir.glob(File.join(output_dir, "#{org_ref}_*"))
        .select { |d| File.directory?(d) }
        .max_by { |d| File.mtime(d) }
    end

    def build_entry(cmd, dir, include_files: false)
      name = File.basename(dir)
      files = Dir.glob(File.join(dir, "**/*")).select { |f| File.file?(f) }

      entry = {
        id: "#{cmd.id}:#{name}",
        path: dir,
        name: name,
        org_ref: name.split("_").first,
        command: cmd.command,
        command_run_id: cmd.id,
        file_count: files.count,
        modified_at: File.mtime(dir)
      }

      entry[:files] = files.map { |f| f.sub("#{dir}/", "") } if include_files
      entry
    end

    def build_file_info(file, export_path)
      {
        name: File.basename(file),
        path: file.sub("#{export_path}/", ""),
        full_path: file,
        size: File.size(file),
        type: detect_file_type(file),
        modified_at: File.mtime(file)
      }
    end
  end
end
