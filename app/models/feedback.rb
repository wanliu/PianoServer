class Feedback < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  paginates_per 10

  validates_presence_of :name, :information
  validates :mobile, presence: {message: '请输入手机号码！'}, format: { with: /\A1[34578]\d{9}\z/, message: '手机号码格式不正确' }

end
