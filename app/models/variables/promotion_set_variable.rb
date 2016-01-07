class PromotionSetVariable < ArrayVariable
  store_accessor :data, :promotion_string
  attr_accessor :promotion_ids

  validates :promotion_string, presence: { message: "请至少选择一个活动！" }

  def call
    Promotion.where(ids: promotion_ids).to_a
  end

  def promotion_ids
    (promotion_string || '').split(',')
  end
end
