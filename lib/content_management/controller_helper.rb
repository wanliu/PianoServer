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

        if with_object.respond_to? :templates
          variables = with_object.templates.includes(:variables).inject([]) {|s, t| s.concat(t.variables) }.uniq { |var| var.name }
          attachments = with_object.templates.includes(:attachments).inject([]) {|s, t| s.concat(t.attachments) }.uniq { |var| var.name }

          load_all_variables variables
          load_attachments attachments
        end

        options.delete(:with)
      end
    end
  end
end
