module ContentManagement
  module ControllerHelper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :render, :content
    end

    def render_with_content(*args, &block)
      pp 'ControllerHelper ContentManagement'
      pp self.lookup_context.class

      render_without_content(*args, &block)
    end

  end
end
