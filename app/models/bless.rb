class Bless < ActiveRecord::Base
  scope :paid, -> { where(paid: true) }

  belongs_to :virtual_present
  belongs_to :birthday_party
  belongs_to :sender, class_name: 'User'

  validates :birthday_party, presence: true
  validates :virtual_present, presence: true
  validates :sender, presence: true

  before_save :copy_virtual_present_infor, on: :create

  private

  def copy_virtual_present_infor
    self.virtual_present_infor = {
      id: virtual_present.id,
      name: virtual_present.name,
      title: virtual_present.title,
      price: virtual_present.price,
      value: virtual_present.value
    }
  end
end
