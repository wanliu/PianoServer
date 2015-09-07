class PromotionSetVariable < ArrayVariable
  store_accessor :data, :promotion_string
  attr_accessor :promotion_ids

  def call
    (promotion_string || '').split(',').map {|id| Promotion.find(id) }
  end

  def promotion_ids
    (promotion_string || '').split(',')
  end
end
