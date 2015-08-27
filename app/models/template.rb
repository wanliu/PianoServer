class Template < ActiveRecord::Base
  ReservedNames = ["homepage_header", "index_template"]

  mattr_accessor :available_variables
  mattr_accessor :constants_variables
  mattr_accessor :customize_variables

  attr_accessor :content

  belongs_to :subject
  has_many :variables

  validates :filename, uniqueness: { scope: :subject_id }
  validates :name, uniqueness: { scope: :subject_id }, allow_nil: true

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

Template.customize_variables = [
  {
    name: 'promotion_variable',
    title: '活动',
    class: PromotionVariable
  }, {
    name: 'promotion_set_variable',
    title: '活动集',
    class: PromotionSetVariable
  }
]
