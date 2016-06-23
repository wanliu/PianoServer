class BirthdayParty < ActiveRecord::Base

  WithdrawStatus = Struct.new(:success, :error_message) do
    alias :success? :success
  end

  mount_uploader :person_avatar, ItemImageUploader

  belongs_to :cake
  belongs_to :user
  belongs_to :order

  has_many :blesses
  has_one :redpack, autosave: true

  validates :cake, presence: true
  validates :user, presence: true
  validates :order, presence: true
  validates :message, presence: true
  validates :birthday_person, presence: true

  def withdraw
    if withdrew > 0
      if redpack.sent?
        WithdrawStatus.new(false, "已经发放过了")
      else
        redpack.send_redpack
      end
    else
      self.withdrew = blesses(true).paid.reduce(0) do |sum, bless|
        sum += bless.virtual_present.value
      end

      if withdrew >= 1
        build_redpack(user: user, amount: withdrew)

        WithdrawStatus.new(save, errors.full_messages.join(', '))
      else
        WithdrawStatus.new(false, "低于一元钱的红包无法领取！")
      end
    end 
  end
end