require 'rails/generators'

module SubjectService
  extend self

  def build(name)
    Rails::Generators.invoke 'subject', [ name ]
  end

  def update_template(subject, template, content)
    file = template_path(subject, template)
    File.write file, content
    logger.info "\033[32mWriting\033[0m to #{file}..."
    logger.debug content
  end

  def subject_root
    File.join(Settings.sites.system.root, "subjects")
  end

  def subject_path(subject)
    File.join(subject_root, subject.name)
  end

  def template_path(subject, template)
    File.join(subject_path(subject), template.filename)
  end

  private
  def logger
    Rails.logger
  end
end
