class Item < ActiveRecord::Base
  include DynamicProperty
  include ContentManagement::Model
  include PublicActivity::Model
  tracked

  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  # paginates_per 5

  acts_as_punchable

  belongs_to :shop_category
  belongs_to :category
  belongs_to :brand
  belongs_to :shop

  has_many :stock_changes, autosave: true

  mount_uploaders :images, ItemImageUploader

  store_accessor :properties, :default_quantity

  attr_accessor :skip_batch
  # dynamic_property prefix: 'property'

  validates :title,:category_id, :shop_id, :brand_id, :sid, presence: true
  validates :shop_category_id, presence: true, unless: :skip_batch
  validates :public_price, numericality: true
  validates :income_price, :price, numericality: true, unless: :skip_batch
  validates :description, length: { minimum: 4 }, unless: :skip_batch

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
    category_id.nil? ? all : includes(:shop_category).where("shop_category_id = ?", category_id)
  end

  scope :with_query, -> (q) do
    q.nil? ? all : where("title like ?", "%#{q}%")
  end

  scope :with_shop, -> (shop_id) do
    shop_id.nil? ? all : where("shop_id = ?", shop_id)
  end

  scope :last_sid, -> (shop) do
    where(shop: shop).maximum(:sid) || 0
  end

  def product
    Product.find(product_id)
  end

  def product=(p)
    self.product_id = p.id
  end

  def filenames
    []
  end

  def image
    images[0] || ItemImageUploader.new(self)
  end

  def avatar_url
    image.url(:avatar)
  end

  def cover_url
    image.url(:cover)
  end

  def description_lookup
    description || category.try(:item_desc)
  end

  def build_stocks(operator, options)
    if options.is_a? Hash
      options.values.each do |option|
        next if option[:value].blank? || option[:value].to_f == 0
        stock_changes.build(data: option[:key], operator: operator, quantity: option[:value], kind: :purchase)
      end
    else
      stock_changes.build(data: {}, operator: operator, quantity: options, kind: :purchase)
    end
  end

  def adjust_stocks(operator, options)
    if options.is_a? Hash
      stocks_origin = stocks_with_index

      stocks_now = StockChange.extract_stocks_with_index(options)
      adjust_options = StockChange.merge_for_adjust(stocks_origin, stocks_now)

      adjust_options.each do |option|
        is_reset = !!option[:data].delete(:is_reset)
        stock_changes.build(data: option[:data], operator: operator, quantity: option[:quantity], kind: :adjust, is_reset: is_reset)
      end
    else
      origin_stock = stock_changes.sum(:quantity)
      adjust_stock = options.to_f - origin_stock
      stock_changes.build(data: {}, operator: operator, quantity: adjust_stock, kind: :adjust)
    end
  end

  # options: {
  #   data: {size: 'l', color: 'red'},
  #   quantity: 1
  # }
  def deduct_stocks!(operator, options)
    stock_changes.create!(data: options[:data], operator: operator, quantity: - options[:quantity], kind: :sale)
  end

  def stocks
    stock_changes.select("sum(quantity) as quantity, data").group("data")
  end

  def stocks_with_index
    stocks.to_a
      .map(&:attributes)
      .reduce({}) do |cache, stock|
        stock["data"] ||= {}
        index = stock["data"].keys.sort.map {|k| "#{k}:#{stock['data'][k]}"}.join(';')
        cache[index] = { quantity: stock["quantity"], data: stock["data"] }
        cache
      end
  end

  def instance_name
    "#{shop.name}_items_#{id}"
  end

  def content_paths
    category_content_paths + [ content_path ]
  end

  def category_content_paths
    category && category.content_paths || []
  end

  def to_param
    sid.to_s
  end

  def update_current_stock!
    update_attributes current_stock: stock_changes(true).sum(:quantity)
  end


  def saleable?(amount=1, props={})
    return false unless (on_sale? && (current_stock > amount))

    if props.present?
      stock_now = stocks.find { |item| item.data == props }.try(:quantity).to_f
      stock_now > amount
    else
      current_stock > amount
    end
  end

  def properties_title(props)
    if props.present?
      return "" if category.blank?

      inventory_properties = category
        .with_upper_properties
        .select { |prop| prop.prop_type == "stock_map" }

      props.map do |key, value|
        prop = inventory_properties.find do |item|
          item.name == key
        end

        "#{prop.title}:#{prop.data["map"][value]}"
      end.join("；")
    else
      ""
    end
  end
end
