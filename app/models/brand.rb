class Brand < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

  paginates_per 100

  has_many :categories
  has_many :items

  acts_as_punchable

  mount_uploader :image, ImageUploader

  attr_reader :title

  def title
    [name, chinese_name].compact.join('/')
  end
end
