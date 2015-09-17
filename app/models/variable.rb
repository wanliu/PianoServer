class Variable < ActiveRecord::Base
  include Variables::Validates

  belongs_to :template

  def call
    data
  end
end
