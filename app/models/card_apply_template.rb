class CardApplyTemplate < ActiveRecord::Base
  enum apply_items: { all_items: 0, include_items: 1 }

  APPLY_ITEMS_TITLES = {"all_items" => "所有商品", "include_items" => "指定商品" }

  has_many :cards, dependent: :nullify

  has_many :card_template_items, autosave: true, inverse_of: :card_apply_template, dependent: :destroy
  has_many :items, through: :card_template_items
  accepts_nested_attributes_for :card_template_items

  validates :title, presence: true, uniqueness: true

  class << self
    def set_default(template)
      where(is_default: true).update_all(is_default: false)
      template.update_column("is_default", true)
    end
  end

  def set_default!
    self.class.set_default(self)
  end

  def desc
    if all_items?
      "适用于所有商品"
    else
      "适用商品: #{items.map(&:title).join(', ')}"
    end
  end
end
