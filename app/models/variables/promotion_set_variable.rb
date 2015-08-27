class PromotionSetVariable < ArrayVariable
  store_accessor :data, :promotion_ids
  attr_accessor :promotion_string

  def call
    unless promotion_string.blank
      promotion_ids = promotion_string.split(',')
      Promotions.find(promotion_ids)
    end
  end
end
