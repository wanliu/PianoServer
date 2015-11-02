class Variable < ActiveRecord::Base
  include Variables::Validates

  belongs_to :host, polymorphic: true

  validates :name, uniqueness: { scope: :host }

  def call
    data
  end
end
