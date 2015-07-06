module JSONOptions
  extend ActiveSupport::Concern

  included do 
    mattr_accessor :action_json_options
    mattr_accessor :action_json_default_config

    self.action_json_options = {}
    self.action_json_default_config = nil
  end

  def _json_options_process
    @json_options = self.action_json_options
    @json_options[_json_model_name] = self.action_json_default_config if @json_options[_json_model_name].nil?
  end

  private 

  def _json_model_name
    params[:controller].split('/').last.singularize.to_sym
  end

  def _json_action_name
    params[:action].to_sym
  end

  module ClassMethods
    # json_options user: simple
    def json_options(config = nil, *args)
      action_json_options.merge!(config) unless config.nil?
      before_action :_json_options_process, *args
    end

    # json_default_options :simple
    # or 
    # json_default_options extract_token, true
    # or 
    # json_default_options extract: image
    def json_default_config(config)
      self.action_json_default_config = config
    end
  end
end
