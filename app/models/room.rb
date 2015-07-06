class Room < ActiveRecord::Base
  belongs_to :roomable
  belongs_to :owner, class_name: 'User'
  belongs_to :target, class_name: 'User'
  has_many :messages, as: :messable

  store_accessor :data, :acceptings
  # 
  # store :data, accessors: [ :acceptings ], coder: JSON

  def acceptings=(value)
    super(value.to_json)
  end

  def acceptings
    JSON.parse(super || "{}")
  end
end
