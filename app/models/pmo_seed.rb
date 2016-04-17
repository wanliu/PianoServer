require 'securerandom'
class PmoSeed < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include Ohm::Callbacks
  include ExpiredEvents

  attribute :seed_id                            # 种子唯一 ID
  attribute :time_out, Type::Integer            # 过期时间
  attribute :timeout_at, OhmTime::ISO8601
  attribute :used, Type::Boolean                # 使用过？
  attribute :used_at, OhmTime::ISO8601
  attribute :owner_id
  attribute :status
  attribute :period, Type::Integer
  attribute :one_money

  reference :pmo_item, :PmoItem
  reference :pmo_grab, :PmoGrab

  reference :given, :PmoUser                    # 给于用户
  # reference :owner, :PmoUser                    # 来源用户

  expire :time_out, :expired_time_out

  index :owner_id
  index :one_money
  index :period
  index :seed_id

  def self.generate(grab, pmo_user, attributes = {})
    pmo_item = grab.pmo_item
    one_money = pmo_item.one_money || OneMoney[grab.one_money.to_i]

    new({
      seed_id: SecureRandom.uuid,
      pmo_grab: grab,
      pmo_item: grab.pmo_item,
      owner_id: pmo_user.id,
      one_money: one_money.id,
    }.merge(attributes))
  end

  def self.last_period(pmo_user, one_money)
    seed = PmoSeed.find(owner_id: pmo_user.id, one_money: one_money.id).max_by { |a| a.period }
    seed.try(:period) || 0
  end

  def before_create
    self.time_out = Settings.promotions.one_money.seed_timeout.minutes.minutes
    self.timeout_at ||= self.now + self.time_out
  end

  def give(pmo_user)
    self.given = pmo_user
  end

  def expired?
    self.timeout_at <= self.now
  end

  def to_hash
    super.merge(attributes.merge(status: status))
  end

  def status
    if owner_id.nil?
      return 'invalid'
    elsif given.nil?
      return 'pending'
    elsif given && !used
      return 'active'
    elsif given && used
      return 'used'
    elsif expired?
      return 'timeout'
    else
      return 'invalid'
    end
  end

  def expired_time_out
    self.delete unless self.given
  end
end
