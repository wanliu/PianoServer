
module ContentManagement

  class Railtie < ::Rails::Railtie

    config.before_initialize do
      ActiveSupport.on_load :action_view do
        include ContentManagement::ViewHelper
        ActionView::LookupContext.send(:include, ContentManagement::LookupContext)
        ActionView::Resolver.send(:include, ContentManagement::Resolver)

      end

      ActiveSupport.on_load :action_controller do
        include ContentManagement::ControllerHelper
      end
    end
  end
end
