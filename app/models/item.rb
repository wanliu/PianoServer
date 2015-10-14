class Item < ActiveRecord::Base
  include DynamicProperty
  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  # paginates_per 5

  acts_as_punchable

  belongs_to :shop_category
  belongs_to :category
  belongs_to :brand
  belongs_to :shop

  has_many :stock_changes, autosave: true

  mount_uploaders :images, ItemImageUploader

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
    category_id.nil? ? all : includes(:shop_category).where("shop_category_id = ?", category_id)
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
        stock_changes.build(data: option[:key], operator: operator, quantity: option[:value], kind: :purchase)
      end
    else
      stock_changes.build(data: {}, operator: operator, quantity: options, kind: :purchase)
    end
  end

  def adjust_stocks(operator, options)
    if options.is_a? Hash
      stocks_origin = stocks_with_index.reduce({}) do |cache, item|
        cache[item["index"]] = { quantity: item["quantity"], data: item["data"] }
        cache
      end

      stocks_adjust = options.values.reduce({}) do |cache, item|
        key = item[:key].keys.sort.map {|k| "#{k}:#{item[:key][k]}"}.join(';')
        cache[key] = { quantity: item[:value], data: item[:key] }
        cache
      end

      adjust_options = stocks_origin.merge(stocks_adjust) do |key, old, new|
        data = new[:data] || old[:data]

        # 对于之前有库存，但是在编辑市取消勾选的项目的处理
        if new[:quantity].blank?
          quantity = - old[:quantity]
          data[:is_reset] = true
        else
          quantity = new[:quantity].to_f - old[:quantity]
        end

        {
          quantity: quantity,
          data: data
        }
      end

      adjust_options = adjust_options.values.select { |item| item[:quantity] != 0 }

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

  def stocks
    stock_changes.select("sum(quantity) as quantity, data").group("data")
  end

  def stocks_with_index
    stocks.to_a
      .map(&:attributes)
      .each { |stock|
        stock["index"] = stock["data"].keys.sort.map {|k| "#{k}:#{stock['data'][k]}"}.join(';')
      }
  end
end
