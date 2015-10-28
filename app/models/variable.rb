class Variable < ActiveRecord::Base
  include Variables::Validates

  belongs_to :host, polymorphic: true

  def call
    data
  end
end
