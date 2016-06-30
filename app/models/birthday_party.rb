class BirthdayParty < ActiveRecord::Base

  attr_accessor :request_ip, :wx_user_openid

  WithdrawStatus = Struct.new(:success, :error_message) do
    alias :success? :success
  end

  mount_uploader :person_avatar, ItemImageUploader

  belongs_to :cake
  belongs_to :user
  belongs_to :order

  has_many :blesses
  has_one :redpack, autosave: true, inverse_of: :birthday_party

  validates :cake, presence: true
  validates :user, presence: true
  validates :order, presence: true
  validates :message, presence: true
  validates :birthday_person, presence: true
  validates :hearts_limit, numericality: { greater_than_or_equal_to: 1 }

  before_validation :set_hearts_limit_from_cake, on: :create

  def withdraw
    if redpack(true).present?
      if redpack.sent?
        WithdrawStatus.new(false, "已经发放过了")
      else
        response = redpack.send_redpack
        WithdrawStatus.new(response.success?, response.error_message)
      end
    else
      self.withdrew = withdrawable

      if withdrew >= 1
        build_redpack(user: user, amount: withdrew, wx_user_openid: wx_user_openid)
        if save
          response = redpack.send_redpack
          WithdrawStatus.new(response.success?, response.error_message)
        else
          WithdrawStatus.new(false, errors.full_messages.join(', '))
        end
      else
        WithdrawStatus.new(false, "低于一元钱的红包无法领取！")
      end
    end
  end

  def withdrawable
    free_hearts_withdrawable + charged_widthdrawable
  end

  private

  def set_hearts_limit_from_cake
    self.hearts_limit = cake.hearts_limit
  end

  def free_hearts_withdrawable
    free_hearts = blesses.free_hearts.paid.limit(hearts_limit)
    # free_hearts = blesses.free_hearts.paid.take(hearts_limit)

    amount = free_hearts.reduce(0) do |sum, bless|
      sum += bless.virtual_present_infor["value"].to_f
    end
  end

  def charged_widthdrawable
    charged_blesses = blesses.charged.paid

    amount = charged_blesses.reduce(0) do |sum, bless|
      sum += bless.virtual_present_infor["value"].to_f
    end
  end
end