class Shop < ActiveRecord::Base
  GREETINGS = %w(您好，请问我有什么可以帮您。 亲，欢迎您光临本店喔。 来者都是客，相逢拱拱手，本店商品玲琅满目、应有尽有，请客官放心挑选)

  include Liquid::Rails::Droppable
  include PublicActivity::Model
  tracked

  enum shop_type: [:retail, :distributor, :wholesaler, :manufacturer ]

  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  acts_as_punchable

  belongs_to :location, autosave: true
  belongs_to :owner, class_name: 'User'
  belongs_to :industry, autosave: true

  has_one :shop_category, dependent: :destroy
  has_many :items
  has_many :members, class_name: "User", foreign_key: 'shop_id'
  has_many :orders, foreign_key: 'supplier_id'

  validates :title, :phone, :name, presence: true
  validates :name, uniqueness: true
  validates :location, presence: { message: '请选择有效城市' }, unless: :skip_validates_or_location

  if Settings.after_registers.shop.validates == "strict"
    validates :description, length: { minimum: 4 }, unless: :skip_validates
    validates :address, presence: true, unless: :skip_validates
  end

  attr_accessor :skip_location, :skip_validates, :skip_validates_or_location


  # delegate :region, to: :location, allow_nil: true

  before_validation :default_values

  store_accessor :settings, :greetings, :theme, :poster

  mount_uploader :logo, ImageUploader

  def skip_validates_or_location
    skip_validates || skip_location
  end

  def avatar_url
    logo.url(:avatar)
  end

  def logo_url_cover
    logo.url(:cover)
  end

  def region
    if region_id.blank?
      location.try :region
    else
      Region.find_by(city_id: region_id)
    end
  end

  def recent_update_location
    activities.where(key: 'shop.update_location').last.try(:updated_at) or DateTime.new(1996)
  end

  def can_change_location?
    recent_update_location + (Settings.shop.location.change_period).days < Time.now
  end

  def change_location?(region_id)
    region_id = region_id.to_i
    region_id > 0 && location && location.region_id != region_id
  end

  protected

  def default_values
    if self.name.blank?
      py_name = Pinyin.t(self.title, splitter: '_')
      self.name = py_name
    end
  end
end

