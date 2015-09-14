class Item < ActiveRecord::Base
  include DynamicProperty


  belongs_to :shop_category
  belongs_to :category
  belongs_to :brand
  belongs_to :shop

  mount_uploaders :images, ImageUploader

  # dynamic_property prefix: 'property'

  validates :shop_category_id, :category_id, :shop_id, :brand_id, presence: true
  validates :title, presence: true
  validates :public_price, :income_price, :price, numericality: true
  validates :description, length: { minimum: 4 }

  if Settings.dev.feature.dynamic_property
    validates :properties, properties: {
      method_prefix: 'property',
      definitions: :definition_properties
    }
  end
    # definitions: -> (item) { Hash[item.definition_properties.map {|name, cfg| ["property_#{name}", cfg] }] }}

  # delegate :name, to: :product
  # delegate :price, to: :product, prefix: true
  # delegate :avatar, to: :product, allow_nil: true
  # delegate :brand_name, to: :product, allow_nil: true
  # delegate :category_id, to: :product, prefix: true
  # delegate :additional_fields, to: :product, allow_nil: true

  delegate :definition_properties, to: :category, allow_nil: true

  scope :with_category, -> (category_id) do
    category_id.nil? ? all : where("shop_category_id = ?", category_id)
  end

  scope :with_query, -> (q) do
    q.nil? ? all : where("title like ?", "%#{q}%")
  end

  scope :with_shop, -> (shop_id) do
    shop_id.nil? ? all : where("shop_id = ?", shop_id)
  end

  def product
    Product.find(product_id)
  end

  def product=(p)
    self.product_id = p.id
  end
end
