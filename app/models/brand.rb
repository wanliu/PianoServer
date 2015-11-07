class Brand < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel
  include PublicActivity::Model
  tracked

  paginates_per 100

  has_many :categories
  has_many :items
  belongs_to :category

  acts_as_punchable

  mount_uploader :image, ItemImageUploader

  attr_reader :title

  def title
    [name, chinese_name].compact.join('/')
  end
end
