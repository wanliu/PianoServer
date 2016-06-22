class BirthdayParty < ActiveRecord::Base

  WithdrawStatus = Struct.new(:withdrew, :error_message)

  mount_uploader :person_avatar, ItemImageUploader

  belongs_to :cake
  belongs_to :user
  belongs_to :order

  has_many :blesses
  has_many :redpacks, auto_save: true

  validates :cake, presence: true
  validates :user, presence: true
  validates :order, presence: true
  validates :message, presence: true
  validates :birthday_person, presence: true

  def withdraw
    if withdrew > 0
      WithdrawStatus.new(false, "已经领取过了")
    else
      self.withdrew = blesses(true).paid.reduce(0) do |sum, bless|
        sum += bless.price
      end

      if withdrew > 1
        redpacks.build(user: user, amount: withdrew)

        WithdrawStatus.new(save, errors.full_messages.join(', '))
      else
        WithdrawStatus.new(false, "低于一元钱的红包无法领取！")
      end
    end 
  end
end
