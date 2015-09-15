require 'chinese_pinyin'

class ShopCategory < ActiveRecord::Base
  acts_as_nested_set

  belongs_to :shop

  has_many :items, foreign_key: :shop_category_id

  # store_accessor :image, :avatar_url

  mount_uploader :image, ImageUploader # , mount_on: :avatar_url

  before_save :default_values
  # alias_method :cover_url, :avatar_url
  # alias_method :logo_url, :avatar_url

  validate :depth_less_or_eq_to_3

  def title
    super || name
  end

  def has_children
    ShopCategory.exists?(parent_id: id)
  end

  def chain_name
    self_and_ancestors.map(&:title)
  end

  def is_leaf
    rgt - lft == 1
  end

  protected

  def default_values
    if self.name.blank?
      py_name = Pinyin.t(self.title, splitter: '_')
      py_name.succ! if same_name?(py_name)
      self.name = py_name
    end
  end

  def same_name?(name)
    nested_set_scope.where(name: name).last.present?
  end

  def depth_less_or_eq_to_3
    if parent.depth >= 3
      errors.add(:depth, "层级过多，最多只能有三级")
    end
  end
end
