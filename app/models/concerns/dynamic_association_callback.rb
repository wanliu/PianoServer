module DynamicAssociationCallback
  extend ActiveSupport::Concern
  CALLBACKS = %w(before_add before_remove after_add after_remove)
  module ClassMethods

    CALLBACKS.each do |name|
      define_method "#{name}_with_proc" do |rel, &block|
        association_callback_method = "#{name}_for_#{rel}"
        association_callbacks = self.send(association_callback_method)
        association_callbacks.push(block)  
      end

      define_method name do |rel, method_sym|
        send "#{name}_with_proc", rel do |callback, owner, item|
          owner.send(method_sym, item)
        end
      end
    end
  end
end
