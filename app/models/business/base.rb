class Business::Base < ActiveRecord::Base
  # 生意模型基类是一个 STI 模型，为 Findgood 等提供了基础的特性
  self.table_name = 'business'

  # 发起人
  belongs_to :started_by, class_name: 'User'
  # 解决人
  belongs_to :resolved_by, class_name: 'User'
  # 当前选择用户
  belongs_to :selected_user, class_name: 'User'

  has_many :business_users, foreign_key: 'business_id'
  # 匹配到的用户
  has_many :matchers, 
    -> { where 'business_users.user_type' => 'matched' }, 
    :through => :business_users, 
    :source => :user
  # 响应参与的用户
  has_many :participants,
    -> { where 'business_users.user_type' => 'participate' }, 
    :through => :business_users, 
    :source => :user
  # 需求项，包括所有需要的内容
  has_many :items, as: :itemable, after_add: :update_items_image, after_remove: :update_items_image
  # 为解决生意需求，打开的房间
  has_many :rooms, as: :roomable
  # 操作日志
  has_many :logs, as: :loggable
  # 相关的日志列表
  has_many :notifies, as: :notifiable

  delegate :login, to: :started_by, prefix: true

  def add_matcher(attributes = {}, *args)
    attributes.merge! user_type: 'matched'
    user_id = attributes[:user_id] || attributes[:user].try(:id)
    business_users.where(user_id: user_id).first_or_create(attributes, *args);
  end

  def add_matchers(objects, *args) 
    business_users.create(objects.map { |obj| obj[:user_type] = 'matched'; obj }, *args)
  end

  def add_participate(attributes = {}, *args)
    attributes.merge! user_type: 'participate'
    user_id = attributes[:user_id] || attributes[:user].try(:id)
    business_users.where(user_id: user_id).create(attributes, *args);
  end

  def add_participants(objects, *args)
    business_users.create(objects.map { |obj| obj[:user_type] = 'participate'; obj }, *args)
  end

  def update_items_image(item)
    if items.count == 1
      update(image: item.image)
    else
    end
  end
end
