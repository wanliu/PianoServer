class Unit < ActiveRecord::Base

  has_many :properties

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true

  paginates_per 10

  def name_title
    if name == title
      name
    else
      "#{name}(#{title})"
    end
  end
end
