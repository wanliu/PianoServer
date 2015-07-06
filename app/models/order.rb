class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :seller, class_name: 'User'

  has_many :items, as: :itemable
end
