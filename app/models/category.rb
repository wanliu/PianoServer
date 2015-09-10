class Category < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

  acts_as_tree :cache_depth => true

  def title
    super || name
  end

  # 伪代码 展开分类显示
  def open
    true
  end
end
