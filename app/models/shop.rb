class Shop < ActiveRecord::Base
  GREETINGS = %w(您好，请问我有什么可以帮您。 亲，欢迎您光临本店喔。 来者都是客，相逢拱拱手，本店商品玲琅满目、应有尽有，请客官放心挑选)

  include Liquid::Rails::Droppable
  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  acts_as_punchable

  belongs_to :location
  belongs_to :owner, class_name: 'User'

  has_one :shop_category
  has_many :items
  has_many :members, class_name: "User", foreign_key: 'shop_id'

  validates :title, :phone, :name, presence: true
  validates :description, length: { minimum: 4 }

  store_accessor :settings, :greetings

  mount_uploader :logo, ImageUploader

  def avatar_url
    logo.url(:avatar)
  end

  def logo_url_cover
    logo.url(:cover)
  end
end
