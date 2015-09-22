class Brand < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

  has_many :categories
  has_many :items

  attr_reader :title

  def title
    [name, chinese_name].join('/')
  end
end
