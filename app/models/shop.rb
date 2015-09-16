class Shop < ActiveRecord::Base
  GREETINGS = %w(您好，请问我有什么可以帮您。 亲，欢迎您光临本店喔。 来者都是客，相逢拱拱手，本店商品玲琅满目、应有尽有，请客官放心挑选)

  include Liquid::Rails::Droppable
  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  acts_as_punchable

  belongs_to :location
  belongs_to :owner, class_name: 'User'

  # has_and_belongs_to_many :categories
  has_one :shop_category
  has_many :items

  store_accessor :settings, :greetings

  mount_uploader :logo, ImageUploader

  alias_method :address, :location

  def avatar_url
    logo.url(:avatar)
  end
end
