class Favorite < ActiveRecord::Base
  belongs_to :favoritor, polymorphic: true
  belongs_to :favoritable, polymorphic: true

  validates :favoritable_id, uniqueness: {
    scope: [:favoritable_type, :favoritor_type, :favoritor_id],
    message: "你已经收藏过了"
  }

  validates :favoritable, presence: true
  validates :favoritor, presence: true
end
