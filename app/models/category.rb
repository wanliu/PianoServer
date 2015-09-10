class Category < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

  acts_as_tree :cache_depth => true

  belongs_to :upper_property, class_name: "Category", foreign_key: 'upper_properties_id'
  has_many :upper_properties, source: :upper_property, source_type: "Category", inverse_of: :properties

  has_and_belongs_to_many :properties

  def title
    super || name
  end

  # 伪代码 展开分类显示
  def open
    true
  end

  def is_leaf
    !has_children?
  end
end
