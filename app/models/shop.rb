class Shop < ActiveRecord::Base
  include Liquid::Rails::Droppable
  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  acts_as_punchable

  belongs_to :location
  belongs_to :owner, class_name: 'User'

  has_one :shop_category
  has_many :items

  store_accessor :image, :avatar_url

  mount_uploader :logo, ImageUploader

  def logo_url_cover
    logo.url(:cover)
  end
end