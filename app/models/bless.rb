class Bless < ActiveRecord::Base
  scope :paid, -> { where(paid: true) }

  belongs_to :virtual_present
  belongs_to :birthday_party
  belongs_to :sender, class_name: 'User'

  validates :birthday_party, presence: true
  validates :virtual_present, presence: true
  validates :sender, presence: true

  def number
    id.to_s.rjust(10, '0')
  end
end
