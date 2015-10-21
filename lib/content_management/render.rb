module ContentManagement
  module Render
    def render(*args)
      pp self.class.ancestors
      pp 'ContentManagement render'
      super
    end

    def render_partial(context, options, &block)
      byebug
      pp 'ContentManagement render', options
      super
    end

    def render_template(context, options)
      byebug
      pp 'ContentManagement render', options
      super
    end
  end
end
