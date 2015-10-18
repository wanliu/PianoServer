module DefaultOptionsHelper
  extend ActiveSupport::Concern

  included do |klass|
    cattr_accessor :global_default_options
    @@global_default_options = {}
  end


  module ClassMethods

    def default_options(meth, options)
      global_default_options[meth] = options

      if instance_methods(false).include?(meth)
        origin_method = "#{meth}_options"
        alias_method origin_method, meth

        define_method meth do |*args, &block|
          _options = args.extract_options!
          args.push _options.deep_merge self.global_default_options[meth]
          send(origin_method, *args, &block)
        end
      else
        define_method meth do |*args, &block|
          _options = args.extract_options!
          args.push _options.deep_merge self.global_default_options[meth]
          super(*args, &block)
        end
      end
    end
  end
end
