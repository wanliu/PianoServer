module ContentManagement
  module ControllerHelper
    include Paths
    include ContentManagementService::Helpers

    private

    def _normalize_options(options)
      super

      template_class = options[:template_class] || TemplateObject

      if with_object = options[:with]
        template_object = template_class.new(with_object)

        # options[:template] = options[:filename] || template_object.view_name(options[:template])
        name, type = template_object.view_name(options[:template])
        if type == :file
          options[:file] = File.join(template_object.path, name)
          options.delete(:template)
        else
          options[:template] = name
        end

        template_object.paths.each do |path|
          push_view_paths path
        end

        load_all_variables with_object.variables if with_object.try(:variables)

        if options[:variables_host].present?
          variables_host = options[:variables_host]
          load_all_variables variables_host.variables
        end

        options.delete(:with)
      end
    end
  end
end
