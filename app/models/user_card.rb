class UserCard < ActiveRecord::Base
  belongs_to :user
  belongs_to :card

  validates :user, presence: true
  validates :card, presence: true

  attr_reader :wx_card_id

  def wx_card_id=(wx_id)
    card = Card.find_by(wx_card_id: wx_id)

    if card.present?
      self.card_id = card.id
    else
      Card.refresh!

      card = Card.find_by(wx_card_id: wx_id)
      if card.present?
        self.card_id = card.id
      end
    end
  end
end
