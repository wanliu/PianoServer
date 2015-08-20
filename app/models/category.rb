class Category < ActiveRecord::Base
  acts_as_nested_set

  has_and_belongs_to_many :shops

  # store_accessor :image, :avatar_url

  mount_uploader :image, ImageUploader # , mount_on: :avatar_url


  # alias_method :cover_url, :avatar_url
  # alias_method :logo_url, :avatar_url
end
