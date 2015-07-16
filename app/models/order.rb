class Order < ActiveRecord::Base
  include ThumbImages
  MIN_AMOUNT = 6

  belongs_to :user
  belongs_to :seller, class_name: 'User'
  belongs_to :supplier, class_name: 'Shop'

  has_many :items, as: :itemable, dependent: :destroy do 
    def build_with_promotion(promotion)
      build({
        title: promotion.title,
        price: promotion.discount_price,
        amount: promotion.try(:amount) || MIN_AMOUNT,
        item_type: 'product',
        iid: Item.last_iid(owner) + 1,
        data: {
          product_id: promotion.product_id,
          image: {
            avatar_url: promotion.image_url,
            preview_url: promotion.preview_url
          }
        }
      })
    end

    def add_promotion(promotion)
      item = where("data -> 'product_id' = :product_id", product_id: promotion.product_id.to_s).first

      if item.nil?
        proxy_association.create({
          title: promotion.title,
          price: promotion.discount_price,
          amount: promotion.try(:amount) || MIN_AMOUNT,
          item_type: 'product',
          iid: Item.last_iid(owner) + 1,
          data: {
            product_id: promotion.product_id
          },
          image: {
            avatar_url: promotion.image_url,
            preview_url: promotion.preview_url
          }
        }) 
      else
        item
      end
    end

    def owner
      proxy_association.owner
    end

  end

  thumb_association :items

  scope :last_bid, -> (buyer_id) {
    where(buyer_id: buyer_id).order(:bid).last.try(:bid) || 0
  }
end
