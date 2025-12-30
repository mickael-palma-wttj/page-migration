# frozen_string_literal: true

class ComparisonsController < ApplicationController
  include ExportFinder

  before_action :set_export, only: [:show]

  def index
    @exports = list_migration_exports
  end

  def show
    @org_ref = extract_org_ref(params[:id])
    @command_run = find_command_run_for_export(params[:id])
    @language = params[:language] || @command_run&.options&.dig("language") || "fr"
    @source_data = load_source_data(@export_path, @language)
    @all_output_files = list_migration_files(@export_path)
  end

  private

  def set_export
    @export_path = find_export_path(params[:id])
    redirect_to comparisons_path, alert: "Export not found" unless @export_path
  end

  def list_migration_exports
    exports = []

    CommandRun.completed.where(command: "migrate").find_each do |cmd|
      data_dir = cmd.export_data_directory
      next unless data_dir.exist?

      migration_dirs(data_dir).each do |dir|
        name = File.basename(dir)
        exports << {
          id: "#{cmd.id}:#{name}",
          org_ref: name.split("_").first,
          name: name,
          command_run_id: cmd.id,
          modified_at: File.mtime(dir)
        }
      end
    end

    exports.sort_by { |e| e[:modified_at] }.reverse
  end

  def migration_dirs(data_dir)
    Dir.glob(File.join(data_dir, "*_*")).select do |dir|
      File.directory?(dir) && File.directory?(File.join(dir, "migration"))
    end
  end

  def load_source_data(export_path, language)
    content_file = File.join(export_path, "contenu_#{language}.json")
    return nil unless File.exist?(content_file)

    JSON.parse(File.read(content_file))
  rescue JSON::ParserError => e
    Rails.logger.error "[Comparisons] Failed to parse source: #{e.message}"
    nil
  end

  def list_migration_files(export_path)
    migration_dir = File.join(export_path, "migration")
    return [] unless File.directory?(migration_dir)

    Dir.glob(File.join(migration_dir, "**", "*.json")).map do |full_path|
      {
        path: full_path.sub("#{migration_dir}/", ""),
        name: File.basename(full_path),
        full_path: full_path,
        size: File.size(full_path),
        type: :json
      }
    end.sort_by { |f| f[:path] }
  end
end
