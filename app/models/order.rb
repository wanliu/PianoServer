class Order < ActiveRecord::Base
  include ThumbImages
  store_accessor :image, :avatar_url

  MIN_AMOUNT = 6

  belongs_to :user
  belongs_to :seller, class_name: 'User'

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
          product_inventory: promotion.product_inventory,
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
        owner.create_status state: :pending

        proxy_association.create({
          title: promotion.title,
          price: promotion.discount_price,
          amount: promotion.try(:amount) || MIN_AMOUNT,
          item_type: 'product',
          iid: Item.last_iid(owner) + 1,
          data: {
            product_id: promotion.product_id,
            product_inventory: promotion.product_inventory
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

  has_one :status, as: :stateable, dependent: :destroy

  thumb_association :items

  delegate :state, to: :status, allow_nil: true

  scope :last_bid, -> (buyer_id) {
    where(buyer_id: buyer_id).order(:bid).last.try(:bid) || 0
  }

  scope :available, -> (shop_id, user_id) {
    where(supplier_id: shop_id, buyer_id: user_id)
  }

  def supplier
    Shop.find(supplier_id)
  end
end
