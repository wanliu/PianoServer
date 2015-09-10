class Category < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

  acts_as_tree :cache_depth => true

  def is_leaf
    !has_children?
  end

  def depth_less_or_eq_to_3
    if parent.depth >= 3
      errors.add(:depth, "层级过多，最多只能有三级")
    end
  end
end
