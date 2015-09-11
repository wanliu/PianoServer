class Brand < ActiveRecord::Base

  has_many :categories
  has_many :items

  attr_reader :title

  def title
    [name, chinese_name].join('/')
  end
end
