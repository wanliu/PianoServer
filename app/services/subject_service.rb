require 'rails/generators'
require 'fileutils'

module SubjectService
  extend self

  def build(name)
    Rails::Generators.invoke 'subject', [ name, "--skip"  ]
  end

  def subject_root
    File.join(Rails.root, Settings.sites.system.root, "subjects")
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
