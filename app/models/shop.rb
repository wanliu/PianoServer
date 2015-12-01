class Shop < ActiveRecord::Base
  GREETINGS = %w(您好，请问我有什么可以帮您。 亲，欢迎您光临本店喔。 来者都是客，相逢拱拱手，本店商品玲琅满目、应有尽有，请客官放心挑选)

  include Liquid::Rails::Droppable
  include PublicActivity::Model
  tracked

  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  acts_as_punchable

  belongs_to :location
  belongs_to :owner, class_name: 'User'

  has_one :shop_category
  has_many :items
  has_many :members, class_name: "User", foreign_key: 'shop_id'

  validates :title, :phone, :name, presence: true
  validates :name, uniqueness: true

  if Settings.after_registers.shop.validates == "strict"
    validates :description, length: { minimum: 4 }
    validates :address, presence: true
  end

  before_validation :default_values

  store_accessor :settings, :greetings, :theme, :poster

  mount_uploader :logo, ImageUploader

  def avatar_url
    logo.url(:avatar)
  end

  def logo_url_cover
    logo.url(:cover)
  end

  protected

  def default_values
    if self.name.blank?
      py_name = Pinyin.t(self.title, splitter: '_')
      self.name = py_name
    end
  end
end

