# frozen_string_literal: true

class ExportsController < ApplicationController
  include ExportFinder

  before_action :set_export, only: [:show, :file]

  def index
    @exports = list_exports
  end

  def show
    @files = list_files(@export_path)
    @org_ref = extract_org_ref(params[:id])
    @command_run = find_command_run_for_export(params[:id])
  end

  def file
    file_path = params[:path]
    full_path = File.join(@export_path, file_path)

    unless valid_file_path?(full_path)
      return redirect_to export_path(params[:id]), alert: "File not found"
    end

    @file_name = File.basename(full_path)
    @file_content = File.read(full_path)
    @file_type = detect_file_type(@file_name)
    @highlighted_content = highlight_content(@file_content, @file_type)

    render "file", formats: [:html]
  end

  private

  def set_export
    @export_path = find_export_path(params[:id])
    redirect_to exports_path, alert: "Export not found" unless @export_path
  end

  def valid_file_path?(full_path)
    File.exist?(full_path) && full_path.start_with?(@export_path)
  end

  def list_files(export_path)
    Dir.glob(File.join(export_path, "**/*"))
      .select { |f| File.file?(f) }
      .map { |file| build_file_info(file, export_path) }
      .sort_by { |f| f[:path] }
  end

  def build_file_info(file, export_path)
    {
      name: File.basename(file),
      path: file.sub("#{export_path}/", ""),
      size: File.size(file),
      type: detect_file_type(file),
      modified_at: File.mtime(file)
    }
  end

  def detect_file_type(filename)
    case File.extname(filename).downcase
    when ".json" then :json
    when ".md", ".markdown" then :markdown
    else :text
    end
  end

  def highlight_content(content, type)
    lexer = lexer_for_type(type)
    formatter = Rouge::Formatters::HTML.new
    formatter.format(lexer.lex(content))
  end

  def lexer_for_type(type)
    case type
    when :json then Rouge::Lexers::JSON.new
    when :markdown then Rouge::Lexers::Markdown.new
    else Rouge::Lexers::PlainText.new
    end
  end
end
