class Thumb < ActiveRecord::Base
  belongs_to :thumber, class_name: 'User'
  belongs_to :thumbable, polymorphic: true

  validates :thumbable, presence: true
  validates :thumber, presence: true
  validates :thumber_id, uniqueness: {
    scope: [:thumbable_type, :thumbable_id],
    message: "你已经赞过了"
  }
end
