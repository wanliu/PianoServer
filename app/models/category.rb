require 'chinese_pinyin'

class Category < ActiveRecord::Base
  acts_as_nested_set

  has_and_belongs_to_many :shops

  has_many :items, foreign_key: :shop_category_id

  # store_accessor :image, :avatar_url

  mount_uploader :image, ImageUploader # , mount_on: :avatar_url

  before_save :default_values

  attr_accessor :is_leaf
  # alias_method :cover_url, :avatar_url
  # alias_method :logo_url, :avatar_url

  def title
    super || name
  end

  def has_children
    Category.exists?(parent_id: id)
  end

  def chain_name
    self_and_ancestors.map(&:name)
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
end
