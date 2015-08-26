class PromotionSetVariable < ArrayVariable
  store_accessor :data, :promotion_ids
  attr_accessor :promotion_string
end
