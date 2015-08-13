class Category < ActiveRecord::Base
  belongs_to :categorable, polymorphic: true

  has_and_belongs_to_many :shops
end
