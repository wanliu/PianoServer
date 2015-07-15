class Order < ActiveRecord::Base
  MIN_AMOUNT = 6

  belongs_to :user
  belongs_to :seller, class_name: 'User'
  belongs_to :supplier, class_name: 'Shop'

  has_many :items, as: :itemable, dependent: :destroy do 
    def build_with_promotion(promotion, *args)
      owner = proxy_association.owner
      build({
        title: promotion.title,
        price: promotion.discount_price,
        amount: promotion.try(:amount) || MIN_AMOUNT,
        item_type: 'product',
        iid: Item.last_iid(owner) + 1,
        data: {
          image: {
            avatar_url: promotion.image_url,
            preview_url: promotion.preview_url
          }
        }
      })
    end
  end

  scope :last_bid, -> (buyer_id) {
    where(buyer_id: buyer_id).order(:bid).last.try(:bid) || 0
  }
end
