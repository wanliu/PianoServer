class Order < ActiveRecord::Base
  include ThumbImages
  store_accessor :image, :avatar_url
  store_accessor :data, :updates, :accept_state, :delivery_address

  MIN_AMOUNT = 6

  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :delivery_location, class_name: 'Location'
  belongs_to :send_location, class_name: 'Location'

  # default_scope do
  #   where(shadow_id: nil)
  # end

  has_many :items, class_name: 'OrderItem', as: :itemable, dependent: :destroy, autosave: true do
    def build_with_promotion(promotion)
      build({
        title: promotion.title,
        price: promotion.discount_price,
        amount: promotion.try(:amount) || MIN_AMOUNT,
        item_type: 'product',
        iid: OrderItem.last_iid(owner) + 1,
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
          iid: OrderItem.last_iid(owner) + 1,
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

    def build_with_shop_product(shop_product)
      build({
        title: shop_product.name,
        price: shop_product.price,
        amount: shop_product.try(:amount) || MIN_AMOUNT,
        item_type: 'product',
        iid: OrderItem.last_iid(owner) + 1,
        data: {
          product_id: shop_product.product_id,
          product_inventory: shop_product.try(:inventory)
        },
        image: {
          avatar_url: shop_product.try(:image_url),
          preview_url: shop_product.try(:preview_url)
        }
      })
    end

    def add_shop_product(shop_product)
      item = where("data -> 'product_id' = :product_id", product_id: shop_product.product_id.to_s).first

      if item.blank?
        owner.create_status state: :pending

        proxy_association.create({
          title: shop_product.name,
          price: shop_product.price,
          amount: shop_product.try(:amount) || MIN_AMOUNT,
          item_type: 'product',
          iid: OrderItem.last_iid(owner) + 1,
          data: {
            product_id: shop_product.product_id,
            product_inventory: shop_product.try(:inventory)
          },
          image: {
            avatar_url: shop_product.try(:image_url),
            preview_url: shop_product.try(:preview_url)
          }
        })
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
      "send_location" => h["send_location"],
      "delivery_location" => h["delivery_location"],
      "business_type" => h["business_type"],
      "title" => h["title"],
      "contacts" => h["contacts"],
      "bid" => h["bid"],
      "sid" => h["sid"],
    }

    hash["items"] = (h["items"] || []).map do |item|
      price = n(item["price"])
      amount = n(item["amount"])
      deleted = item["deleted"].blank? ? false : item["deleted"]
      sub_total = n(item["sub_total"].nil? ? price * amount : item["sub_total"])
      sub_total = price * amount
      total += deleted ? 0 : sub_total

      {
        "id" => item["id"],
        "title" => item["title"],
        "iid" => item["iid"],
        "item_type" => item["item_type"],
        "price" => price,
        "amount" => amount,
        "sub_total" => sub_total,
        "unit" => item["unit"],
        "unit_title" => item["unit_title"],
        "deleted" => deleted
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

  ITEMS_CHILDREN_REG = /items\[(\d+)\]\.(\w+)/
  ITEMS_REG = /items\[(\d+)\]/

  def update_patch(attrs)
    diffs = HashDiff.best_diff origin_hash, attrs
    Order.transaction do

      diffs.each do |op, path, src, dest|
        case op
        when '~'
          if ITEMS_CHILDREN_REG =~ path
            m = ITEMS_CHILDREN_REG.match(path)
            index, method = m[1].to_i, m[2]
            items[index].send(method + '=', dest)
          else
            self.send(path + '=', dest)
          end
        when '+'
          if ITEMS_REG =~ path
            m = ITEMS_REG.match(path)
            index = m[1]
            items.push dest
          end
        when '-'
          if ITEMS_REG =~ path
            m = ITEMS_REG.match(path)
            index = m[1].to_i
            item = items[index]
            items.delete item
          end
        end
      end

      data[:updates] = nil
      updates = nil

      save
    end
    # Order.transaction do
    #   _items = attrs.delete "items" || []

    #   update_attributes(attrs)
    #   items.destroy_all

    #   _items.each do |item|
    #     items.build item
    #   end
    #   data[:updates] = nil
    #   save
    # end
  end

  def delivery_address_title
    if delivery_location_id == nil or delivery_location_id < 0
      (delivery_address || {})["location"] || ''
    else
      delivery_location.try(:full_address)
    end
  end

  private

  def n(num)
    num.nil? ? nil : BigDecimal.new(num)
  end
end
