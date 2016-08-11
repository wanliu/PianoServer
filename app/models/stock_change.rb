class StockChange < ActiveRecord::Base
  belongs_to :item
  belongs_to :unit
  belongs_to :operator, class_name: 'User'
  belongs_to :operation, polymorphic: true

  validates :quantity, numericality: true
  validates :item, presence: true

  enum kind: { 
    purchase: 0, 
    sale: 1, 
    sale_refund: 2, 
    stock_refund: 3, 
    adjust: 4,
    gift: 5
  }

  validate :quantity_check

  after_commit :update_item_current_stock

  # Change form like:
  #  {"0"=>{"key"=>{"length"=>"2em", "weight"=>"a"}, "value"=>"7.0"},
  # "1"=>{"key"=>{"length"=>"2em", "weight"=>"b"}, "value"=>"4.0"}}
  # To:
  # {"length:2em;weight:c"=> {:quantity=>"7.0", :data=>{"length"=>"2em", "weight"=>"c"}},
  # "length:2em;weight:d"=> {:quantity=>"4.0, :data=>{"length"=>"2em", "weight"=>"d"}}}
  def self.extract_stocks_with_index(options)
    options.values.reduce({}) do |cache, item|
      key = item[:key].keys.sort.map {|k| "#{k}:#{item[:key][k]}"}.join(';')
      cache[key] = { quantity: item[:value], data: item[:key], price_offset: item[:price_offset] }
      cache
    end
  end

  # 根据比较原始库存和目标库存，返回用于生成库存调节的条目
  # stocks_origin(原库存):
  # {
  #   "length:2em;weight:c"=> {:quantity=>"7.0", :data=>{"length"=>"2em", "weight"=>"c"}},
  #   "length:2em;weight:d"=> {:quantity=>"4.0", :data=>{"length"=>"2em", "weight"=>"d"}}
  #   "length:2em;weight:f"=> {:quantity=>"3.0", :data=>{"length"=>"2em", "weight"=>"f"}}
  # }

  # stocks_now(目标库存):
  # {
  #   "length:2em;weight:c"=> {:quantity=>"5.0", :data=>{"length"=>"2em", "weight"=>"c"}},
  #   "length:2em;weight:d"=> {:quantity=>"6.0", :data=>{"length"=>"2em", "weight"=>"d"}},
  #   "length:2em;weight:e"=> {:quantity=>"7.0", :data=>{"length"=>"2em", "weight"=>"e"}}
  # }

  # result(调整库存):
  # [
  #   {:quantity=>-2, :data=>{"length"=>"2em", "weight"=>"c"}},  # 5 -7 = -2
  #   {:quantity=>2, :data=>{"length"=>"2em", "weight"=>"d"}},   # 6 -4 = 2
  #   {:quantity=>7, :data=>{"length"=>"2em", "weight"=>"e"}},   # 7 -0 = 7
  #   {:quantity=>-3, :data=>{"length"=>"2em", "weight"=>"f", is_reset: true}}   # 0 -3 = -3 (目标库存０，因为目标库存中已经不存在对应的data)
  # ]
  def self.merge_for_adjust(stocks_origin, stocks_now)
    origin_keys = stocks_origin.keys
    now_keys = stocks_now.keys

    intersection_keys = origin_keys & now_keys
    full_keys = origin_keys | now_keys

    adjust_options = full_keys.map do |key|
      data = stocks_now[key].try(:[], :data) || stocks_origin[key].try(:[], :data) || {}

      quantity = if intersection_keys.include? key
        stocks_now[key][:quantity].to_f - stocks_origin[key][:quantity]
      elsif origin_keys.include? key
        data[:is_reset] = true
        -stocks_origin[key][:quantity]
      elsif now_keys.include? key
        stocks_now[key][:quantity].to_f
      end

      { quantity: quantity, data: data }
    end

    adjust_options.select { |item| item[:quantity] != 0 }
  end

  private

  def quantity_check
    if purchase? && quantity.present? && quantity <= 0
      errors.add(:quantity, "不能为零或者小于零")
    end
  end

  def update_item_current_stock
    item.update_current_stock! if persisted?
  end
end
