class CartItem < ActiveRecord::Base
  enum sale_mode: [:retail, :wholesale]

  attr_accessor :sale_mode

  belongs_to :cart, touch: true
  belongs_to :supplier, class_name: "Shop"

  belongs_to :cartable, polymorphic: true

  validates :price, :quantity, numericality: { greater_than: 0 }
  validates :supplier, presence: true
  validates :cart_id, presence: true
  # validates :properties, presence: true
  validates :cartable_id, uniqueness: { scope: [:cart_id, :cartable_type, :properties] }

  validate :avoid_from_shop_owner
  validate :cartable_saleable
  before_save :set_properties

  delegate :title, to: :cartable, allow_nil: true

  def cartable
    if cartable_type == 'Promotion'
      Promotion.find(cartable_id)
    else
      super
    end
  end

  def quantity
    super || default_quantity
  end

  def default_quantity
    if cartable && cartable.respond_to?(:default_quantity)
      cartable.default_quantity || 1
    else
      1
    end
  end

  def avatar_url
    if cartable_type == 'Promotion'
      cartable.image_url
    elsif cartable_type == 'Item'
      cartable.avatar_url
    end
  end

  def properties_title(props=properties)
    if cartable.is_a?(Item) && props.present?
      cartable.properties_title(props)
    else
      ""
    end
  end

  # input:
  #   options: {"17"=>"-1.0", "19"=>"2", "22"=>"2"}
  # output:
  # [ {gift_id: 17, item_id: 1, quantity: 0, title: 'xxx', avatar_url: 'cvxxx.jpg'},
  #   {gift_id: 19, item_id: 2, quantity: 1, title: 'xxx', avatar_url: 'cvxxx.jpg'},
  #   {gift_id: 22, item_id: 3, quantity: 2, title: 'xxx', avatar_url: 'cvxxx.jpg'} ]
  def gift_settings(options)
    if cartable.respond_to?(:gifts)
      cartable.gifts.where(id: options.keys).reduce([]) do |settings, gift|
        quantity = options[gift.id.to_s].try(:to_i) || 0
        if quantity > 0
          settings.push({
            gift_id: gift.id,
            item_id: gift.present_id,
            properties: gift.properties,
            quantity: quantity,
            title: gift.composed_title,
            avatar_url: gift.avatar_url
          })
        end

        settings
      end 
    end
  end

  private

  def avoid_from_shop_owner
    if supplier.owner_id == cart.user_id
      errors.add(:supplier_id, "不能购买自己店里的商品")
    end
  end

  def cartable_saleable
    cartable.saleable?(quantity, properties) do |on_sale, saleable, max|
      if !on_sale
        errors.add(:orderable_id, "已经下架")
      elsif !saleable
        errors.add(:quantity, max.to_i.to_s)
      end
    end
  end

  def set_properties
    if properties.nil?
      self.properties = {}
    end
  end
end
