# frozen_string_literal: true

module ExportFinder
  extend ActiveSupport::Concern

  private

  def find_export_path(id)
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
    if id.include?(":")
      _, export_name = id.split(":", 2)
      export_name.split("_").first
    else
      id.split("_").first
    end
  end

  def find_command_run_for_export(id)
    return nil unless id.include?(":")

    cmd_id, _ = id.split(":", 2)
    CommandRun.find_by(id: cmd_id)
  end

  def list_exports(scope: CommandRun.completed, limit: nil, org_ref: nil, include_files: false)
    exports = []

    query = scope.order(created_at: :desc)
    query = query.limit(limit) if limit

    pattern = org_ref ? "#{org_ref}_*" : "*_*"

    query.find_each do |cmd|
      data_dir = cmd.export_data_directory
      next unless data_dir.exist?

      Dir.glob(File.join(data_dir, pattern)).select { |d| File.directory?(d) }.each do |dir|
        exports << build_export_entry(cmd, dir, include_files: include_files)
      end
    end

    exports.sort_by { |e| e[:modified_at] }.reverse
  end

  def export_exists?(org_ref)
    CommandRun.completed.find_each do |cmd|
      data_dir = cmd.export_data_directory
      next unless data_dir.exist?
      return true if Dir.glob(File.join(data_dir, "#{org_ref}_*")).any?
    end
    false
  end

  def build_export_entry(cmd, dir, include_files: false)
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
end
