class Item < ActiveRecord::Base
  belongs_to :shop_category
  belongs_to :category
  belongs_to :brand
  belongs_to :shop

  mount_uploaders :images, ImageUploader

  validates :shop_category, presence: true
  validates :shop, presence: true
  validates :price, presence: true
  validates :product_id, presence: true
  validates :brand, :category, presence: true

  # delegate :name, to: :product
  # delegate :price, to: :product, prefix: true
  # delegate :avatar, to: :product, allow_nil: true
  # delegate :brand_name, to: :product, allow_nil: true
  # delegate :category_id, to: :product, prefix: true
  # delegate :additional_fields, to: :product, allow_nil: true

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

  def method_missing(method, *args)
    name = method.to_s
    super unless name.start_with?('property_')
    property_name = name[9, -1]
    if property_name.end_with?('=')
      write_property(property_name[0, -2], *args)
    else
      read_property(property_name, *args)
    end
  end

  def write_property(name, value)

  end

  def read_property(name)

  end
end
