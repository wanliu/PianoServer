require 'wx_avatar_downloader'

class BirthdayParty < ActiveRecord::Base

  paginates_per 10

  attr_accessor :request_ip, :wx_user_openid, :skip_validates

  WithdrawStatus = Struct.new(:success, :error_message) do
    alias :success? :success
  end

  mount_uploader :person_avatar, ItemImageUploader
  store_accessor :data, :properties

  belongs_to :cake, -> { with_deleted }
  belongs_to :user
  belongs_to :order

  # NOTE these is a user, not a sales_man
  belongs_to :sales_man, class_name: 'User'

  has_many :blesses
  has_many :redpacks, autosave: true, inverse_of: :birthday_party

  validates :cake, presence: true, unless: :skip_validations
  validates :user, presence: true, unless: :skip_validations
  validates :order, presence: true, unless: :skip_validations
  validates :message, presence: true, unless: :skip_validations
  validates :birth_day, presence: true
  validates :birthday_person, presence: true
  validates :hearts_limit, numericality: { greater_than_or_equal_to: 1 }, unless: :skip_validations

  before_validation :set_hearts_limit_from_cake, on: :create

  after_commit :send_confirm_to_buyer, on: :create
  after_commit :send_sms_to_sales_man, on: :create
  after_commit :send_confirm_to_shop_owner, on: :create

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
    return false unless order.finish?

    build_unwithdrew_redpacks

    send_unsent_redpacks
  end

  def withdrew(force=false)
    force ? redpacks.sum(:amount) : super()
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

  def free_hearts_withdrawable
    free_hearts = blesses.free_hearts.paid.limit(hearts_limit)

    # free_hearts.sum("cast(virtual_present_infor->>'value' AS float)")
    free_hearts.reduce(0) do |sum, bless|
      sum += bless.virtual_present_infor["value"].to_f
      sum
    end
  end

  def charged_widthdrawable
    charged_blesses = blesses.charged.paid

    charged_blesses.sum("cast(virtual_present_infor->>'value' AS float)")
  end

  def delivery_deadline
    if delivery_time.present?
      delivery_time.strftime("%Y年%m月%d日%H点")
    else
      birth_day.strftime("%Y年%m月%d日")
    end
  end

  def skip_validations
    skip_validates
  end

  def properties_title(props=properties)
    cake.item.properties_title(props)
  end

  private

  def set_hearts_limit_from_cake
    self.hearts_limit = cake.hearts_limit if hearts_limit.blank?
  end


  def build_unwithdrew_redpacks
    withdrew_cache = withdrew(true)
    withdrawable_cache = get_withdrawable

    withdraw_amount = withdrawable_cache - withdrew_cache

    if withdraw_amount >= 1
      self.withdrew = withdrawable_cache

      while withdraw_amount > 200 do
        withdraw_amount -= 200

        redpacks.build(user: user, amount: 200, wx_user_openid: wx_user_openid)
      end

      if withdraw_amount >= 1
        redpacks.build(user: user, amount: withdraw_amount, wx_user_openid: wx_user_openid)
      end

      save
    end
  end

  def send_unsent_redpacks
    options = {
      failed: Redpack.statuses["failed"],
      unknown: Redpack.statuses["unknown"]}

    redpacks.where("status = :failed OR status = :unknown", options)
      .map(&:send_redpack)
  end

  def send_confirm_to_buyer
    return if skip_validations
    return unless persisted? && Settings.cakes.sms.notify_buyer

    if cake.shop.try(:phone).present?
      template = Settings.cakes.sms.buyer_template
      service_phone = cake.shop.phone
    else
      template = Settings.cakes.sms.buyer_template_without_phone
      service_phone = nil
    end

    if template.present?
      cake_name = cake.try(:title)
      address = order.delivery_address

      text = template.sub("#cakename#", cake_name).sub("#date#", delivery_deadline).sub("#address#", address)

      text = text.sub("#phone#", service_phone) if service_phone.present?
      # text = "【耒阳街上】您订购的生日趴蛋糕:#{cake_name}成功, 蛋糕将于#{delivery_time}送到#{address},请注意查收!"

      NotificationSender.delay.notify({"mobile" => order.receiver_phone, "text" => text})
    end
  end

  # 【耒阳街上】由您推荐的"#name#的生日趴"创建成功！可在个人中心(http://m.wanliu.biz/profile)查看，或者访问地址：#url# 查看.
  def send_sms_to_sales_man
    return if skip_validations
    return unless persisted? && sales_man.present? && Settings.cakes.sms.notify_sales_man

    real_sales_man = SalesMan.find_by(shop_id: cake.shop.id, user_id: sales_man_id)

    mobile = if real_sales_man.present?
      real_sales_man.phone
    else
      sales_man.mobile
    end

    template = Settings.cakes.sms.sales_man_template

    if mobile.present? && template.present?
      url = "#{Settings.app.website}#{ApplicationController.helpers.birthday_party_path(self)}"

      text = template.sub("#name#", birthday_person).sub("#url#", url)

      NotificationSender.delay.notify({"mobile" => mobile, "text" => text})
    end
  end

  def send_confirm_to_shop_owner
    return if skip_validations
    return unless persisted? && Settings.cakes.sms.notify_shop_owner

    if cake.shop.try(:phone).present?
      service_phone = cake.shop.phone
      template = Settings.cakes.sms.shop_owner_template

      if template.present?
        text = template.sub("#orderid#", order_id.to_s)
        NotificationSender.delay.notify({"mobile" => service_phone, "text" => text})
      end
    end
  end
end
