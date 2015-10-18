module DefaultOptionsHelper
  extend ActiveSupport::Concern

  # included do |klass|
  #   DefaultOptionsHelper.setup_module(klass)
  # end

  # def self.setup_module(mod)
  #   mod.module_eval <<-RUBY
  #     def self.included(klass)
  #       install_default_options(klass)
  #     end
  #   RUBY
  # end

  module ClassMethods
    @@default_options = {}

    def default_options(meth, options)
      define_method "#{meth}_with_default_options" do |*args, &block|
        _options = args.extract_options!
        # default_options = eval_options @@default_options[meth], self
        options = _options.deep_merge @@default_options[meth]
        send("#{meth}_without_default_options", *args, options, &block)
      end

      @@default_options[meth] = options
      alias_method_chain meth, :default_options
    end

    # def install_default_options(mod)
    #   @@default_options.each do |meth, options|
    #     install_default_options_method(mod, meth)
    #   end
    # end

    # def install_default_options_method(mod, meth)
    #   mod.send :define_method, "#{meth}_with_default_options" do |*args, &block|
    #     _options = args.extract_options!
    #     global_default_options = DefaultOptionsHelper::ClassMethods.class_variable_get(:@@default_options)
    #     options = _options.deep_merge global_default_options[meth]
    #     send("#{meth}_without_default_options", *args, options, &block)
    #   end

    #   mod.alias_method_chain meth, :default_options
    # end
  end
end
