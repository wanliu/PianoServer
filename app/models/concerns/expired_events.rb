module ExpiredEvents
  extend ActiveSupport::Concern
  include ActiveSupport::Callbacks

  included do |klass|
    klass.class_attribute :expire_attributes, :time_redis

    klass.time_redis = redis
    # @@expire_attributes = {}
    klass.expire_attributes = {}
    if instance_methods(true).include?(:after_save)
      alias_method_chain :after_save, :expire
    end
  end

  def cancel_expire(attribute)
    key_name = "#{key}:__expires:#{attribute}"
    time_redis.call("EXPIREAT", key_name, 0) if time_redis.call("EXISTS", key_name)
  end

  def expire_status
    status = {}
    self.expire_attributes.each do |key, v|
      status[key] = expire_ttl(key)  if v
    end
    status
  end

  def now
    redis_time = time_redis.call('time').map &:to_i
    Time.at(*redis_time)
  end

  def expire_ttl(attribute)
    key_name = "#{key}:__expires:#{attribute}"
    ttl = time_redis.call("TTL", key_name)
  end

  def expire_running?(attribute)
    expire_ttl(attribute) > 0
  end

  def set_expire_time(attribute, time)
    key_name = "#{key}:__expires:#{attribute}"
    time_redis.call("SET", key_name, 1)
    time_redis.call("EXPIREAT", key_name, time)
  end

  def after_save_with_expire

    self.expire_attributes.each do |key, v|
      if v
        set_expire_time(key, self.send(key).to_i)
      end
    end

    after_save_without_expire
  end

  module ClassMethods

    def expire(attribute, method)
      define_callbacks attribute
      set_callback attribute, :after, method


      self.expire_attributes[attribute] = true
    end
  end
end
