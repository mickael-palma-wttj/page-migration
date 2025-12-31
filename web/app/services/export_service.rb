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

  ID_SEPARATOR = ":"

  class << self
    def find_path(id)
      cmd_id, export_name = parse_id(id)

      if cmd_id
        cmd = CommandRun.find_by(id: cmd_id)
        return nil unless cmd

        path = File.join(cmd.export_data_directory, export_name)
        return path if File.directory?(path)
      end

      legacy_path = File.join(PageMigration::Config::DEFAULT_OUTPUT_ROOT, export_name)
      legacy_path if File.directory?(legacy_path)
    end

    def extract_org_ref(id)
      _, export_name = parse_id(id)
      export_name.split("_").first
    end

    def find_command_run(id)
      cmd_id, _ = parse_id(id)
      return nil unless cmd_id

      CommandRun.find_by(id: cmd_id)
    end

    def list(scope: CommandRun.completed, limit: nil, org_ref: nil, include_files: false)
      exports = []
      query = scope.order(created_at: :desc)
      query = query.limit(limit) if limit
      pattern = org_ref ? "#{org_ref}_*" : "*_*"

      query.find_each do |cmd|
        find_directories(cmd.export_data_directory.to_s, pattern).each do |dir|
          exports << build_entry(cmd, dir, include_files: include_files)
        end
      end

      exports.sort_by { |e| e[:modified_at] }.reverse
    end

    def exists?(org_ref)
      CommandRun.completed.find_each do |cmd|
        return true if find_directories(cmd.export_data_directory.to_s, "#{org_ref}_*").any?
      end
      false
    end

    def list_files(export_path)
      find_files(export_path)
        .map { |file| build_file_info(file, export_path) }
        .sort_by { |f| f[:path] }
    end

    def find_export_id_for_org(org_ref, command_run: nil)
      export_dir = find_latest_export_dir(org_ref, command_run: command_run)
      return nil unless export_dir

      build_export_id(command_run, File.basename(export_dir))
    end

    def find_export_files_for_org(org_ref, command_run: nil)
      export_dir = find_latest_export_dir(org_ref, command_run: command_run)
      return [] unless export_dir

      export_id = build_export_id(command_run, File.basename(export_dir))

      find_files(export_dir)
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

    def parse_id(id)
      return [nil, id] unless id.include?(ID_SEPARATOR)

      id.split(ID_SEPARATOR, 2)
    end

    def build_export_id(command_run, folder_name)
      command_run ? "#{command_run.id}#{ID_SEPARATOR}#{folder_name}" : folder_name
    end

    def find_directories(base_path, pattern)
      return [] unless Dir.exist?(base_path)

      Dir.glob(File.join(base_path, pattern)).select { |d| File.directory?(d) }
    end

    def find_files(base_path, pattern = "**/*")
      Dir.glob(File.join(base_path, pattern)).select { |f| File.file?(f) }
    end

    def find_latest_export_dir(org_ref, command_run: nil)
      output_dir = command_run&.export_data_directory&.to_s || PageMigration::Config::DEFAULT_OUTPUT_ROOT
      find_directories(output_dir, "#{org_ref}_*").max_by { |d| File.mtime(d) }
    end

    def build_entry(cmd, dir, include_files: false)
      name = File.basename(dir)
      files = find_files(dir)

      entry = {
        id: build_export_id(cmd, name),
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
