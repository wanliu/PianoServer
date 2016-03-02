class Item < ActiveRecord::Base
  include DynamicProperty
  include ContentManagement::Model
  include PublicActivity::Model
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

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

  delegate :region_id, to: :shop, prefix: true

  if Settings.dev.feature.dynamic_property
    validates :properties, properties: {
      method_prefix: 'property',
      definitions: :definition_properties
    }
  end

  settings(index: {
      analysis: {
        analyzer: {
            pinyin_analyzer: {
              tokenizer: "my_pinyin",
              filter: ["word_delimiter", "nGram"]
            }
        },
        tokenizer: {
          my_pinyin: {
            type: "pinyin",
            first_letter: "prefix",
            padding_char: " "
          }
        }
      }
    }) do

    mappings dynamic: 'true' do
      indexes :title, 
        type: 'string', 
        analyzer: 'ik',
        fields: {
          pinyin: {
            type: 'string', 
            analyzer: 'pinyin_analyzer',
            term_vector: "with_positions_offsets"
          }
        }
      indexes :shop_name, type: 'string'
      indexes :brand_id, type: 'long'
      indexes :category_id, type: 'long'
      indexes :shop_category_id, type: 'long'
      indexes :shop_id, type: 'long'
      indexes :current_stock, type: 'float'
      indexes :description, type: 'string', analyzer: 'ik'
      indexes :on_sale, type: 'boolean'
      indexes :abandom, type: 'boolean'
      indexes :price, type: 'float'
      indexes :income_price, type: 'float'
      indexes :public_price, type: 'float'
      indexes :properties, type: 'object'
      indexes :sid, type: 'long'
      indexes :shop_region_id, type: 'long'
      # indexes :pinyin, type: 'string', analyzer: 'pinyin_analyzer'
    end
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

  scope :with_shop_or_product, -> (q) do
    groups = q.split(/[,，。　 ]/)
    shop_name = groups[0]
    product = groups[1..-1].join('')

    query = {
      query: {
        bool: {
          should: [
            {
              query_string: {"default_field" => "item.shop_name","query" => shop_name }
            }
          ]
        }
      }
    }

    if product.present?
      if product.to_i > 0
        query[:query][:bool][:should].push({
          "range":{"item.sid": {"from" => product,"to" => product }}
        })
      else
        query[:query][:bool][:should].push({
          query_string: {"default_field" => "item.title","query" => product }
        })
      end
    end

    Item.search(query).records #.results
  end

  scope :search_leiyang_items, ->(params) do
    leiyang_region_id = Settings.elasticsearch.default_region_id

    query_params = {
      query: {
        bool: {
          should: [
            { match: {"title.pinyin" => params[:q]} },
            { match: {title: params[:q]} }
          ],
          filter: [
            {
              term: {
                shop_region_id: leiyang_region_id
              }
            },
            {
              term: {
                on_sale: true
              }
            }
          ],
          minimum_should_match: 1
        }
      }
    }

    if params[:category_id].present?
      query_params[:query][:bool][:filter].push({
        term: {
          category_id: params[:category_id]
        }
      })
    end

    min_score = Settings.elasticsearch.item_min_score
    if min_score.present?
      query_params[:min_score] = min_score
    end

    Item.search(query_params)
  end

  def as_indexed_json(options={})
    self.as_json(methods: [:shop_region_id, :shop_name])
  end

  def pinyin
    Pinyin.t title
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

  def shop_name
    shop.try(:title)
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
    unless on_sale?
      yield false, false, 0 if block_given?
      return false
    end

    stock = (current_stock || 0)

    if props.present?
      props_stock = stocks.find { |item| item.data == props }.try(:quantity).to_f
      yield true, props_stock >= amount, props_stock if block_given?
      props_stock >= amount
    else
      yield true, stock >= amount, stock if block_given?
      stock >= amount
    end
  end

  def properties_title(props)
    if props.present?
      props.map do |key, value|
        prop = properties.find do |prop_name, v|
          prop_name == key
        end

        prop = prop[1]

        if prop.present?
          "#{prop['title']}:#{prop['value'][value].try(:[], 'title')}"
        else
          ""
        end
      end.join(";")
    else
      ""
    end
  end

  def properties_name
    properties.map { |key, value| value['title'] }
  end

  def inventory_properties
    properties.select do |property, prop_values|
      "stock_map" == prop_values['prop_type']
    end
  end

  def properties_setting
    super.map do |property|
      keys = Property.attribute_names - ["id"]
      Property.new property.slice(*keys)
    end
  end
end