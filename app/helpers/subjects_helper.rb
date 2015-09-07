require 'content_management/subject/file_system'

module SubjectsHelper
  def subject_render(subject, template, *args)
    options = args.extract_options!

    if options[:partial] && subject.nil?
      render options
    elsif subject.nil?
      return
    else
      tpl = subject.templates.find_by(name: template)
      if tpl.nil?
        render options
      elsif is_partial?(tpl.filename)
        path = File.join("subjects", subject.name, tpl.filename.sub(/^views\/_/, 'views/'))
        render({ partial: path }.reverse_merge(options))
      else
        path = File.join("subjects", subject.name, tpl.filename)
        set_file_system subject
        render path
      end
    end
  end

  protected

  def set_file_system(subject)
    Liquid::Template.file_system = ContentManagement::Subject::FileSystem.new(subject_views_path(subject), "_%s.html.liquid".freeze)
  end

  private

  def is_partial?(filename)
    File.basename(filename).start_with?('_')
  end

  def prefix_path(subject, filename)
    File.join("subjects", subject.name, filename)
  end

  def subject_views_path(subject)
    File.join(subject_root, 'subjects', subject.name, 'views')
  end

  def subject_root
    Rails.root.join(Settings.sites.system.root).to_s
  end
end

