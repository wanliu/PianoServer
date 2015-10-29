class Subject < ActiveRecord::Base
  include ContentManagement::Model

  RESERVED_NAMES = ["homepage_header", "index", "promotion"]

  include Liquid::Rails::Droppable

  enum status: [ :open, :close ]

  acts_as_punchable

  class_attribute :default_templates

  has_many :templates, as: :templable

  validates :title, presence: true
  validates :name, uniqueness: true
  validates :start_at, presence: true
  validates :end_at, presence: true


  before_validation :default_values
  after_create :create_subject_files

  scope :availables, -> do
    where("start_at <= ? and end_at >= ? and status = ?", Time.now, Time.now, 0)
  end

  def name_reserved?(name)
    RESERVED_NAMES.include? name
  end

  def content_root
    File.join(Rails.root, Settings.sites.system.root, "subjects")
  end

  protected

  def default_values
    if self.name.blank?
      py_name = Pinyin.t(self.title, splitter: '_')
      py_name.succ! if same_name?(py_name)
      self.name = py_name
    end
  end

  def same_name?(name)
    self.class.where(name: name).last.present?
  end

  def create_subject_files
    SubjectService.build(name)
  end

end

Subject.default_templates = [
  PageTemplate.new(name: 'index', filename: 'views/subjects/index.html.liquid', templable: Subject.new),
  PartialTemplate.new(name: 'promotion', filename: 'views/promotions/_promotion.html.liquid', templable: Subject.new),
  HomepageTemplate.new(name: 'homepage_header', filename: 'views/promotions/_homepage_header.html.liquid', templable: Subject.new)
]

