class PmoUser < Ohm::Model
  ALIVE_TIMES = 50
  # TEMP_USER_ALIVE_TIMES =

  include Ohm::Timestamps
  include Ohm::DataTypes
  include Ohm::Callbacks
  include ExpiredEvents

  attribute :username
  attribute :mobile
  attribute :email
  attribute :avatar_url

  attribute :title
  attribute :user_id
  attribute :sex

  index :user_id

  def after_create
    if user_id < 0
      redis.call("EXPIRE", key, ALIVE_TIMES)
      redis.call("EXPIRE", "#{key}:_indices", ALIVE_TIMES)
      redis.call("EXPIRE", "PmoUser:indices:user_id:#{user_id}", ALIVE_TIMES)
    end
  end

  def self.from(user)
    new({
      username: user.username,
      mobile: user.mobile,
      email: user.email,
      title: user.nickname,
      avatar_url: user.avatar_url,
      user_id: user.id,
      sex: user.sex
    })
  end
end
