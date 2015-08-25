class Template < ActiveRecord::Base

  attr_accessor :content

  belongs_to :subject
  has_many :variables

  def content
    @content ||= File.read template_path
  end

  def update_attributes_with_content(attributes)
    content = attributes.delete(:content)
    update_attributes_without_content(attributes)
    SubjectService.update_template(subject, self, content)
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

  alias_method_chain :update_attributes, :content
end
