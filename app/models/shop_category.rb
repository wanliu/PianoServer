require 'chinese_pinyin'

class ShopCategory < ActiveRecord::Base
  LIMITED_DEPTH = 3
  include PublicActivity::Model
  tracked

  html_fragment :description, :scrub => :prune  # scrubs `body` using the :prune scrubber

  acts_as_nested_set

  paginates_per 12

  acts_as_punchable

  belongs_to :shop

  has_many :items, foreign_key: :shop_category_id

  validates :name, presence: true

  store_accessor :data, :category

  mount_uploader :image, ItemImageUploader # , mount_on: :avatar_url

  before_validation :default_values
  before_create do |record|
    record.iid = ShopCategory.last_iid(record.root.try(:shop)) + 1
  end
  # alias_method :cover_url, :avatar_url
  # alias_method :logo_url, :avatar_url
  scope :last_iid, -> (shop) do
    return 0 if shop.blank?
    where(shop_id: shop.try(:id)).maximum(:iid) || 0
  end

  validate :out_of_depth

  def title
    super || name
  end

  def has_children
    ShopCategory.exists?(parent_id: id)
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
    if parent.present? && parent.depth >= LIMITED_DEPTH
      errors.add(:depth, "层级过多，最多只能有三级")
    end
  end
end
