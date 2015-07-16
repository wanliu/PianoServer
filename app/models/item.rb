require_relative '../serializers/hash_serializer'

class Item < ActiveRecord::Base
  belongs_to :itemable, polymorphic: true
  serialize :data, HashSerializer
  # serialize :image
  store_accessor :data, :image
  scope :last_iid, -> (target) do 
    where(itemable: target).order(:iid).last.try(:iid) || 0
  end
end
