class ExpressTemplate < ActiveRecord::Base
  belongs_to :shop

  has_many :applied_items, class_name: 'Item', dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :shop_id }
  validates :shop, presence: true

  validate :default_exists

  private

  def default_exists
    if !free_shipping && default_empty?
      errors.add(:base, "默认运费不能为空")
    end
  end

  def default_empty?
    default = template["default"]
    default.blank? || default["first_quantity"].blank? || default["first_fee"].blank?
  end
end
