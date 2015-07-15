class Item < ActiveRecord::Base
  belongs_to :itemable, polymorphic: true

  scope :last_iid, -> (target) do 
    where(itemable: target).order(:iid).last.try(:iid) || 0
  end
end
