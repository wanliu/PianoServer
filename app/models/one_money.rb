class OneMoney < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include Ohm::Callbacks
  include OhmTime
  include ExpiredEvents

  attribute :name
  attribute :title
  attribute :description
  attribute :header
  attribute :footer

  attribute :start_at, OhmTime::ISO8601
  attribute :end_at, OhmTime::ISO8601
  attribute :suspend_at, OhmTime::ISO8601
  attribute :fare, Type::Decimal
  attribute :max_free_fare, Type::Decimal
  attribute :multi_item, Type::Integer   # 可以抢多种商品设置
  attribute :auto_expire, Type::Boolean  # 自动同步记时器
  attribute :callback

  attribute :cover_url
  attribute :head_url
  attribute :publish_url
  attribute :status
  attribute :type

  attribute :shares, Type::Integer        # 分享次数
  attribute :share_seed, Type::Integer    # 分享种子数

  attribute :price, Type::Decimal
  attribute :is_open, Type::Boolean       # 是否打开
  attribute :items_with_gifts             # 礼品购的商品

  collection :items, :PmoItem
  collection :seeds, :PmoSeed

  set :signups, :PmoUser
  set :participants, :PmoUser
  set :winners, :PmoUser

  # list :grabs, :PmoGrab

  # expire :start_at, :expired_start_at
  # expire :end_at, :expired_end_at

  counter :hits

  index :name
  index :type
  index :start_at
  index :is_open

  attr_accessor :query

  def to_key
    attributes[:id].nil? ? [] : [id.to_s]
  end

  def to_hash
    super.merge(attributes.except(:callback))
  end

  def before_create
    self.multi_item = 1
    self.auto_expire = true
  end

  def after_save
    self.items.each do |item|
      unless item.independence # 未独立
        # if self.start_at > Time.now && item.status == "end" # 设置了新的开始时间，要把状态改为未开始
        #   item.status = ""
        #   item.save
        # end
        #
        # if self.end_at > Time.now && item.status == "started" # 结束时间如果小于当前时间，要提前结束
        #   item.status = ""
        #   item.save
        # end

        # item.set_expire_time(:start_at, self.start_at.to_i)
        # Rails.logger.info "Set start_at Expire Time #{self.start_at}" if self.start_at && self.now < self.start_at
        # item.set_expire_time(:end_at, self.end_at.to_i)
        # Rails.logger.info "Set end_at Expire Time #{self.end_at}" if self.end_at && self.now < self.end_at
      end
    end
  end

  def item_status
    status = []

    shop_item_ids = items.map(&:item_id)
    shop_items = Item.where(id: shop_item_ids)

    unless shop_items.all?(&:on_sale)
      status.push "包含已下架商品！"
    end

    unless shop_items.all? { |item| item.current_stock.to_i > 0 }
      status.push "包含库存不足商品！"
    end

    "<span style='color:red'>#{status.join('<br>')}</span>".html_safe
  end

  private

  def expired_start_at
    self.status = 'started'
    save
  end

  def expired_end_at
    self.status = 'end'
    save
  end
end
