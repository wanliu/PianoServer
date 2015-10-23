class Contact < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ActivityService.current_user,
          recipient: ActivityService.system_admin,
          parameters: :tracked_values

  validates_presence_of :name, :message, message: '不可以为空！'
  validates :mobile, presence: {message: '请输入手机号码！'}, format: { with: /\A1[34578]\d{9}\z/, message: '手机号码格式不正确' }

  has_one :status, as: :stateable, dependent: :destroy

  default_scope do
  	joins('LEFT JOIN "statuses" ON "statuses"."stateable_id" = "contacts"."id" AND "statuses"."stateable_type" = \'Contact\'')
  		.where("statuses.state = 0 or statuses.state is null")
  end


  def tracked_values
    {}.tap do |hash|
      hash[:name] = name
      hash[:reason] = message
      hash[:telephone] = mobile
    end
  end

end
