class PromotionVariable < ObjectVariable

  store_accessor :data, :promotion_id

  validates :promotion_id, presence: { message: "请选中一个活动！" }

  def call
    Promotion.find(promotion_id) unless promotion_id.nil?
  end
end
