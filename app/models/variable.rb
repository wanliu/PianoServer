class Variable < ActiveRecord::Base
  belongs_to :template

  validates :name, presence: true

  def call
    data
  end
end
