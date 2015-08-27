class PromotionSetVariable < ArrayVariable
  store_accessor :data, :promotion_ids
  attr_accessor :promotion_string

  def call
    (promotion_string || '').split(',').map {|id| Promotions.find(id) }
  end
end
