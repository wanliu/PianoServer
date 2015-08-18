class Category < ActiveRecord::Base
  acts_as_nested_set

  has_and_belongs_to_many :shops

  has_many :items, foreign_key: :shop_category_id

  store_accessor :image, :avatar_url

  alias_method :cover_url, :avatar_url
  alias_method :logo_url, :avatar_url

  def has_children
    Category.exists?(parent_id: id)
  end

  def path
    if parent_id.present?
      Category.find(parent_id).path << self
    else
      [self]
    end
  end

  def chain_name
    path.map(&:name)
  end
end
