module ApplicationHelper
  include Pagy::Frontend

  # Delegate export lookups to ExportService
  def find_export_id_for_org(org_ref, command_run: nil)
    ExportService.find_export_id_for_org(org_ref, command_run: command_run)
  end

  def find_export_files_for_org(org_ref, command_run: nil)
    ExportService.find_export_files_for_org(org_ref, command_run: command_run)
  end

  # Syntax highlighting for file content
  def highlight_file_content(content, type)
    ExportService.highlight(content, type)
  end

  # Markdown rendering
  def render_markdown(content)
    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      link_attributes: {target: "_blank", rel: "noopener"}
    )
    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      underline: true,
      highlight: true,
      no_intra_emphasis: true
    )
    markdown.render(content).html_safe
  end

  # File browser helpers
  def extract_folders_from_files(files)
    folders = Set.new
    files.each do |file|
      parts = file[:path].split("/")
      (1...parts.length).each { |i| folders << parts[0...i].join("/") }
    end
    folders.to_a.sort
  end

  def folder_parent(folder_path)
    parts = folder_path.split("/")
    (parts.length > 1) ? parts[0...-1].join("/") : ""
  end

  def file_directory(file_path)
    parts = file_path.split("/")
    (parts.length > 1) ? parts[0...-1].join("/") : ""
  end
end
