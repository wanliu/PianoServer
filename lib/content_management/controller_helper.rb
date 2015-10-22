module ContentManagement
  module ControllerHelper
    include Paths

    private

    def _normalize_options(options)
      super

      template_class = options[:template_class] || TemplateObject

      if with_object = options[:with]
        template_object = template_class.new(with_object)

        options[:template] = options[:filename] || template_object.view_name(options[:template])

        template_object.paths.each do |path|
          push_view_paths path
        end
        options.delete(:with)
      end
    end
  end
end
