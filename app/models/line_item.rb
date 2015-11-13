require_relative '../serializers/hash_serializer'

class LineItem < ActiveRecord::Base
  belongs_to :itemable, polymorphic: true
  # serialize :data, HashSerializer
  # serialize :image, HashSerializer

  scope :last_iid, -> (target) do
    where(itemable: target).order(:iid).last.try(:iid) || 0
  end

  def sub_total
    super.nil? ? calc_sub_total : super
  end

  def calc_sub_total
    price * amount
  end
end