class CardTemplateItem < ActiveRecord::Base
  belongs_to :card_apply_template
  belongs_to :item

  validates :card_apply_template, presence: true
  validates :item, presence: true, uniqueness: { scope: :card_apply_template_id }
end
