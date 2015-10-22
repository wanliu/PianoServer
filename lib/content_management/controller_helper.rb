module ContentManagement
  module ControllerHelper
    include Paths

    private

    def _normalize_render(*args, &block)
      options = _normalize_args(*args, &block)
      template_class = options[:template_class] || TemplateObject

      if with_object = options[:with]
        template_object = template_class.new(with_object)

        options[:template] = options[:filename] || template_object.view_name(options[:template])

        template_object.paths.each do |path|
          push_view_paths path
        end
      end

      #TODO: remove defined? when we restore AP <=> AV dependency
      if defined?(request) && request.variant.present?
        options[:variant] = request.variant
      end
      _normalize_options(options)
      options
    end

  end
end
