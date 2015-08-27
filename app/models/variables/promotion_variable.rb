class PromotionVariable < ObjectVariable

  store_accessor :data, :promotion_id


  def call
    Promotion.find(promotion_id) unless promotion_id.nil?
  end
end
