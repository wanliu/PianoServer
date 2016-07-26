require 'wx_avatar_downloader'

class BirthdayParty < ActiveRecord::Base

  paginates_per 5

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

  # scope :feedback -> {}

  # scope :bless_group -> { blesses.count(:all, group: 'name' ) }

  def self.rank
    select_statement = <<-SQL
      coalesce(sum(cast(blesses.virtual_present_infor->>'value' as float)), 0) as vv,
      sum(case when blesses.virtual_present_infor @> '#{Bless.free_hearts_hash.to_json}' then 1 else 0 end) as fc,
      count(blesses.id) as bc,
      birthday_parties.*
    SQL

    BirthdayParty.joins("left join blesses on blesses.birthday_party_id = birthday_parties.id and blesses.paid = 't'")
      .select(select_statement)
      .group("id")
      .order("vv desc, id desc")
  end

  def withdraw
    unless order.finish?
      return WithdrawStatus.new(false, "订单尚未完成，请在订单完成（收货）后再试！")
    end

    if redpack(true).present?
      if redpack.sent? || redpack.received? || redpack.sending?
        WithdrawStatus.new(false, "已经发放过了")
      else
        response = redpack.send_redpack
        WithdrawStatus.new(response.success?, response.error_message)
      end
    else
      self.withdrew = get_withdrawable

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

  def update_withdrawable
    update_column('withdrawable', get_withdrawable)
  end

  def get_withdrawable
    free_hearts_withdrawable + charged_widthdrawable
  end

  def download_avatar_media
    WxAvatarDownloader.perform_async(id)
  end

  # TODO 使用后台任务，定时（每天一次／两次）计算排名，写入字段保存
  def rank_position
    # ids = self.class.rank.map(&:id)
    # ids.index(id) + 1

    select_statement = <<-SQL
      coalesce(sum(cast(blesses.virtual_present_infor->>'value' as float)), 0) as vv,
      birthday_parties.id
    SQL

    anteriors = BirthdayParty.joins("left join blesses on blesses.birthday_party_id = birthday_parties.id and blesses.paid = 't'")
      .select(select_statement)
      .group("id")
      .having("coalesce(sum(cast(blesses.virtual_present_infor->>'value' as float)), 0) > ?", all_blesses_value)

    anteriors.length + 1
  end

  def all_blesses_value
    blesses.paid.sum("cast(virtual_present_infor->>'value' AS float)")
  end

  private

  def set_hearts_limit_from_cake
    self.hearts_limit = cake.hearts_limit
  end

  def free_hearts_withdrawable
    free_hearts = blesses.free_hearts.paid.limit(hearts_limit)

    free_hearts.sum("cast(virtual_present_infor->>'value' AS float)")
  end

  def charged_widthdrawable
    charged_blesses = blesses.charged.paid

    charged_blesses.sum("cast(virtual_present_infor->>'value' AS float)")
  end
end
