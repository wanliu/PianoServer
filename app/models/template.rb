class Template < ActiveRecord::Base

  belongs_to :subject

  attr_accessor :content

  def content
    @content ||= File.read template_path
  end

  protected

  def subject_root
    File.join(Settings.sites.system.root, "subjects")
  end

  def subject_path
    File.join(subject_root, subject.name)
  end

  def template_path
    File.join(subject_path, filename)
  end
end
