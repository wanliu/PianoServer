class Subject < ActiveRecord::Base
  include Liquid::Rails::Droppable

  acts_as_punchable

  has_many :templates

  validates :title, presence: true
  validates :name, uniqueness: true
  validates :start_at, presence: true
  validates :end_at, presence: true


  before_save :default_values
  after_create :create_subject_files

  scope :availables, -> do
    where("start_at <= ? and end_at >= ?", Time.now, Time.now)
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
