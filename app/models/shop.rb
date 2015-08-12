class Shop < ActiveRecord::Base
  belongs_to :location
  belongs_to :owner, class_name: 'User'

  store_accessor :image, :avatar_url


  alias_method :address, :location
  alias_method :logo_url, :avatar_url
end
