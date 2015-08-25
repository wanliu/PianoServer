class Shop < ActiveRecord::Base
  include Liquid::Rails::Droppable

  belongs_to :location
  belongs_to :owner, class_name: 'User'

  has_and_belongs_to_many :categories
  has_many :items

  store_accessor :image, :avatar_url


  alias_method :address, :location
  alias_method :logo_url, :avatar_url
end
