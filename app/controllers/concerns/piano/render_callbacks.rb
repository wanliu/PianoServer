module Piano
  module RenderCallbacks
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks
      define_callbacks :render
    end

    def render(*args)
      run_callbacks :render do
        super *args
      end
    end

    module ClassMethods

      def before_render(name_or_block)
        set_callback :render, :before, name_or_block
      end

      def after_render(name_or_block)
        set_callback :render, :after, name_or_block
      end
    end
  end
end
