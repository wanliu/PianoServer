class Order < ActiveRecord::Base
  include ThumbImages
  store_accessor :image, :avatar_url
  store_accessor :data, :updates, :accept_state

  MIN_AMOUNT = 6

  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :delivery_location, class_name: 'Location'
  belongs_to :send_location, class_name: 'Location'

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

  def buyer
    buyer_id && buyer_id < 0 ? User.anonymous(buyer_id) : super
  end

  def origin_hash
    attrs = attributes
    attrs["items"] = items.map {|item| item.attributes }
    to_hash(attrs)
  end

  def update_hash
    if updates.nil?
      origin_hash
    else
      to_hash(updates)
    end
  end

  def to_hash(target)
    h = target || {}

    total = 0
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
    }
    hash["items"] = (h["items"] || []).map do |item|
      price = n(item["price"])
      amount = n(item["amount"])
      sub_total = n(item["sub_total"].nil? ? price * amount : item["sub_total"])
      sub_total = price * amount
      total += sub_total
      {
        "id" => item["id"],
        "title" => item["title"],
        "iid" => item["iid"],
        "item_type" => item["item_type"],
        "price" => price,
        "amount" => amount,
        "sub_total" => sub_total,
        "unit" => item["unit"],
        "unit_title" => item["unit_title"]
      }
    end
    hash["total"] = n(h["total"].nil? ? total : h["total"])
    hash["total"] = total
    hash
  end

  def apply_patch(patchs)
    to_hash(JSON::Patch.new(update_hash, patchs).call)
  end

  def calc_total
    items.inject(0) do |s, item |
      s += item.sub_total
    end
  end

  def total
    super.nil? ? calc_total : super
  end

  def update_patch(attrs)
    Order.transaction do
      _items = attrs.delete "items" || []

      update_attributes(attrs)
      items.destroy_all

      _items.each do |item|
        items.build item
      end
      data[:updates] = nil
      save
    end
  end

  private

  def n(num)
    num.nil? ? nil : BigDecimal.new(num)
  end
end
