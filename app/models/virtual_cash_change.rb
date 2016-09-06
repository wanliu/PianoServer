class VirtualCashChange < ActiveRecord::Base
  enum kind: { promotion: 1, buy: 2, spend: 3, earn: 4 }

  belongs_to :user

  validates :user, presence: true
  validates :amount, presence: true
end
