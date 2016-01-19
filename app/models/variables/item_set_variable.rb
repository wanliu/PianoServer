class ItemSetVariable < ArrayVariable
  store_accessor :data, :items_string
  attr_accessor :item_ids

  validates :items_string, presence: { message: "请至少选择一个商品！" }

  def call
    Item.where(id: item_ids)
  end

  def item_ids
    (items_string || '').split(',')
  end
end
