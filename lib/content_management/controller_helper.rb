module ContentManagement
  module Helpers
    VALID_VAR_NAME = /\A[_\p{letter}]+[\p{Alnum}_]*\z/

    def load_attachments(attachments=all_attachments)
      @attachments = attachments
      @images = ImagesDrop.new(@attachments)
    end

    def all_attachments
      get_subject.templates.includes(:attachments).inject([]) {|s, t| s.concat(t.attachments) }
    end

    protected

    # 获取模板对象
    def get_template(name)
      cached_all_templates
      if cached_all_templates[name].nil?
        cached_all_templates[name] = get_subject.templates.find_by(name: name)
      else
        cached_all_templates[name]
      end
    end

    def load_all_variables(_variables)
      @all_variables ||= {}
      _variables.each do |variable|
        value = variable.call if variable.respond_to?(:call)
        if VALID_VAR_NAME =~ variable.name
          name = '@' + variable.name
          instance_variable_set name.to_sym, value
        end
        @all_variables[variable.name] = value
      end

      @variables = VariablesDrop.new(@all_variables)
    end

    def get_subject
      throw StandardError.new 'must have subject instance' if @subject.nil?
      @subject
    end

    def merge_variables(_variables)
      _variables.uniq { |var| var.name }
    end
  end

  module ControllerHelper
    include Paths
    include ContentManagement::Helpers

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
          variables = with_object.templates.includes(:variables)
            .inject([]) {|s, t|
              s.concat(t.variables)
            }.uniq { |var| var.name }

          attachments = with_object.templates.includes(:attachments)
            .inject([]) {|s, t|
              s.concat(t.attachments)
            }.uniq { |var| var.name }

          load_all_variables variables
          load_attachments attachments
        end

        options.delete(:with)
      end
    end
  end
end
