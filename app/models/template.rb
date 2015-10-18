class Template < ActiveRecord::Base

  mattr_accessor :available_variables
  mattr_accessor :constants_variables
  mattr_accessor :customize_variables

  attr_accessor :content

  belongs_to :templable, polymorphic: true
  has_many :variables, dependent: :destroy
  has_many :attachments, dependent: :destroy, as: :attachable

  validates :filename, uniqueness: { scope: [:templable_type, :templable_id] }, presence: true
  validates :name, uniqueness: { scope: [:templable_type, :templable_id] }, presence: true

  def content
    content!
  rescue
  ensure
    nil
  end

  def content!
    @content ||= File.read template_path unless template_path.nil?
  end

  def update_attributes_with_content(attributes)
    content = attributes.delete(:content)
    update_attributes_without_content(attributes)
    ContentManagementService.update_template(self, content)
  end

  def template_path
    File.join(templable.path, filename)
  rescue
    nil
  end

  def empty?
    content.nil?
  end

  def reserved?
    templable.try(:name_reserved?, name)
  end

  protected

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
