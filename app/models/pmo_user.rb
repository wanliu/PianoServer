class PmoUser < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include ExpiredEvents

  attribute :username
  attribute :mobile
  attribute :email
  attribute :avatar_url

  attribute :title
  attribute :user_id
  attribute :sex


  index :user_id

  def before_create
    if self.id < 0
    end
    # self.status = "pending"
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
