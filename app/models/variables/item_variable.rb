class ItemVariable < ObjectVariable

  store_accessor :data, :item_id

  validates :item_id, presence: { message: "请选中一个商品！" }

  def call
    Item.find(item_id) unless item_id.nil?
  end
end
