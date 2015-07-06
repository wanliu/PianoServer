module ConcernParentResource
  extend ActiveSupport::Concern

  included do |klass|
    cattr_accessor :parent_param
    cattr_accessor :parent_param_options

    before_action :find_parent
  end

  def find_parent
    parent_param = self.class.parent_param
    parent_param_options = self.class.parent_param_options
    if params[parent_param]
      value = params[parent_param]
      klass_name = parent_param_options[:class_name] ? parent_param_options[:class_name] : parent_param.to_s.chomp('_id')
      @parent = klass_name.classify.constantize.find(value)
    end
  end

  module ClassMethods
    def set_parent_param(name, options = {})
      self.parent_param = name
      self.parent_param_options = options
    end
  end
 end
