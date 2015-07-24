require_relative '../serializers/hash_serializer'

class Item < ActiveRecord::Base
  self.table_name = "items"

  belongs_to :itemable, polymorphic: true
  # serialize :data, HashSerializer
  # serialize :image, HashSerializer

  scope :last_iid, -> (target) do 
    where(itemable: target).order(:iid).last.try(:iid) || 0
end