class Order < ActiveRecord::Base
  include ThumbImages
  store_accessor :image, :avatar_url
  store_accessor :data, :updates

  MIN_AMOUNT = 6

  belongs_to :user
  belongs_to :seller, class_name: 'User'

  # default_scope do
  #   where(shadow_id: nil)
  # end

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

  def initialize(attributes, *args)
    attrs = attributes.dup
    items = attrs.delete("items")
    super(attrs) do |order|
      (items || []).each do |item|
        order.items.build(item)
      end
    end
  end

  def supplier
    Shop.find(supplier_id)
  end

  def origin_hash
    # dont use symbol of key please, because attributes, jsonb data all is string keys
    hash = {
      "id" => id,
      "buyer_id" => buyer_id,
      "seller_id" => seller_id,
      "supplier_id" => supplier_id,
      "send_address" => send_address,
      "delivery_address" => delivery_address,
      "business_type" => business_type,
      "title" => title,
      "contacts" => contacts,
      "bid" => bid,
      "sid" => sid,
      "total" => total
    }
    hash["items"] = items.map do |item|
      {
        "id" => item.id,
        "title" => item.title,
        "iid" => item.iid,
        "item_type" => item.item_type,
        "price" => item.price,
        "amount" => item.amount,
        "sub_total" => item.sub_total,
        "unit" => item.unit,
        "unit_title" => item.unit_title
      }
    end
    hash
  end

  def update_hash
    if updates.nil?
      origin_hash
    else
      h = updates || {}
      hash = {
        "id" => h["id"],
        "buyer_id" => h["buyer_id"],
        "seller_id" => h["seller_id"],
        "supplier_id" => h["supplier_id"],
        "send_address" => h["send_address"],
        "delivery_address" => h["delivery_address"],
        "business_type" => h["business_type"],
        "title" => h["title"],
        "contacts" => h["contacts"],
        "bid" => h["bid"],
        "sid" => h["sid"],
        "total" => n(h["total"])
      }
      hash["items"] = (h["items"] || []).map do |item|
        {
          "id" => item["id"],
          "title" => item["title"],
          "iid" => item["iid"],
          "item_type" => item["item_type"],
          "price" => n(item["price"]),
          "amount" => n(item["amount"]),
          "sub_total" => n(item["sub_total"]),
          "unit" => item["unit"],
          "unit_title" => item["unit_title"]
        }
      end
      hash
    end
  end

  private

  def n(num)
    num.nil? ? nil : BigDecimal.new(num)
  end
end
