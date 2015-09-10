class Shop < ActiveRecord::Base
  include Liquid::Rails::Droppable

  acts_as_punchable

  belongs_to :location
  belongs_to :owner, class_name: 'User'

  # has_and_belongs_to_many :categories
  has_one :shop_category
  has_many :items

  store_accessor :image, :avatar_url

  mount_uploader :logo, ImageUploader

  alias_method :address, :location
  # alias_method :logo_url, :avatar_url
end
