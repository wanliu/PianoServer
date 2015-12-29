module ExpiredEvents
  extend ActiveSupport::Concern
  include ActiveSupport::Callbacks

  module ClassMethods

    def expire(attribute, method)
      define_callbacks attribute

      set_callback attribute, :after, method

      define_method "#{attribute}_with_expired=" do |value|
        # run_callbacks attribute do
        unless new?
          key_name = "#{key}:__expires:#{attribute}"
          redis.call("SET", key_name, 1)
          redis.call("EXPIREAT", key_name, value.to_i)
        end
        send("#{attribute}_without_expired=", value)
        # end
      end

      alias_method_chain "#{attribute}=", :expired
    end
  end
end
