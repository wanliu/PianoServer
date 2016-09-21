class Card < ActiveRecord::Base
  validates :wx_card_id, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  validates :available_range, presence: true

  enum available_range: { "礼品购" => 0 }
end
