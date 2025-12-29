module ApplicationHelper
  # Find the export ID (folder name) for an org_ref within a command run's data directory
  def find_export_id_for_org(org_ref, command_run: nil)
    output_dir = command_run&.export_data_directory&.to_s || PageMigration::Config::DEFAULT_OUTPUT_ROOT
    return nil unless Dir.exist?(output_dir)

    # Find the most recent export folder for this org_ref
    dirs = Dir.glob(File.join(output_dir, "#{org_ref}_*"))
      .select { |d| File.directory?(d) }
      .sort_by { |d| File.mtime(d) }
      .reverse

    dirs.first ? File.basename(dirs.first) : nil
  end

  # Find all export files for an org_ref within a command run's data directory
  def find_export_files_for_org(org_ref, command_run: nil)
    output_dir = command_run&.export_data_directory&.to_s || PageMigration::Config::DEFAULT_OUTPUT_ROOT
    return [] unless Dir.exist?(output_dir)

    # Find the most recent export folder for this org_ref
    export_dir = Dir.glob(File.join(output_dir, "#{org_ref}_*"))
      .select { |d| File.directory?(d) }
      .max_by { |d| File.mtime(d) }

    return [] unless export_dir

    export_id = File.basename(export_dir)

    Dir.glob(File.join(export_dir, "**/*"))
      .select { |f| File.file?(f) }
      .map do |file|
        relative_path = file.sub("#{export_dir}/", "")
        {
          name: File.basename(file),
          path: relative_path,
          full_path: file,
          size: File.size(file),
          export_id: export_id,
          type: detect_file_type(file)
        }
      end
      .sort_by { |f| f[:path] }
  end

  def detect_file_type(filename)
    case File.extname(filename).downcase
    when ".json" then :json
    when ".md", ".markdown" then :markdown
    else :text
    end
  end

  def highlight_file_content(content, type)
    lexer = case type
    when :json then Rouge::Lexers::JSON.new
    when :markdown then Rouge::Lexers::Markdown.new
    else Rouge::Lexers::PlainText.new
    end

    formatter = Rouge::Formatters::HTML.new
    formatter.format(lexer.lex(content))
  end

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

  def render_file_content(content, type)
    case type
    when :markdown
      render_markdown(content)
    else
      highlight_file_content(content, type)
    end
  end

  def extract_folders_from_files(files)
    folders = Set.new
    files.each do |file|
      path = file[:path]
      parts = path.split("/")
      # Add all parent folders
      (1...parts.length).each do |i|
        folders << parts[0...i].join("/")
      end
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
