class Contact < ActiveRecord::Base
  validates_presence_of :name, :message, message: '不可以为空！'
  validates :mobile, presence: {message: '请输入手机号码！'}, format: { with: /\A1[34578]\d{9}\z/, message: '手机号码格式不正确' }
end
