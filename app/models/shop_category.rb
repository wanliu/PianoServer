require 'chinese_pinyin'

class ShopCategory < ActiveRecord::Base
  LIMITED_DEPTH = 3

  acts_as_nested_set

  belongs_to :shop

  has_many :items, foreign_key: :shop_category_id

  validates :name, presence: true

  # store_accessor :image, :avatar_url

  mount_uploader :image, ImageUploader # , mount_on: :avatar_url

  before_validation :default_values
  # alias_method :cover_url, :avatar_url
  # alias_method :logo_url, :avatar_url

  validate :out_of_depth

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

  def depth_limited_reached
    depth >= LIMITED_DEPTH
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

  def out_of_depth
    if parent.depth >= LIMITED_DEPTH
      errors.add(:depth, "层级过多，最多只能有三级")
    end
  end
end
