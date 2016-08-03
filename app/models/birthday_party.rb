require 'wx_avatar_downloader'

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
  has_many :redpacks, autosave: true, inverse_of: :birthday_party

  validates :cake, presence: true
  validates :user, presence: true
  validates :order, presence: true
  validates :message, presence: true
  validates :birthday_person, presence: true
  validates :hearts_limit, numericality: { greater_than_or_equal_to: 1 }

  before_validation :set_hearts_limit_from_cake, on: :create

  def withdraw
    withdraw_amount = withdrawable - withdrew

    if withdraw_amount > 1
      self.withdrew += withdraw_amount

      amounts = []
      times = (withdraw_amount/200).floor
      left = withdraw_amount%200

      times.times { amounts << 200 }
      amounts << left if left >= 1

      amounts.each do |amount|
        redpacks.build(user: user, amount: amount, wx_user_openid: wx_user_openid)
      end 

      save
    end

    redpacks(true) do |redpack|
      if redpack.failed? || redpack.unknown?
        redpack.send_redpack
      end
    end
  end

  def withdrawable
    free_hearts_withdrawable + charged_widthdrawable
  end

  def download_avatar_media
    WxAvatarDownloader.perform_async(id)
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