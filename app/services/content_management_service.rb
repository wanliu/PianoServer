module ContentManagementService
  module ContentController
    extend ActiveSupport::Concern

    included do |klass|
      cattr_accessor :content_templates
      attr_accessor :cached_all_templates

      define_method :cached_all_templates do
        @cached_all_templates ||= {}
      end

      @@content_templates = []

      before_action :check_subject_variables
    end

    def check_subject_variables
      prepare_load_variables unless @subject.nil?
    end

    # 预载入所有模板中的 Variable
    def prepare_load_variables
      load_variables = []
      self.content_templates.each do |section|
        if valid_section?(section)
          template = get_template(section[:name])
          if template && template.is_a?(Template)
            load_variables.concat template.variables
          end
        end
      end

      variables = merge_variables(load_variables)

      load_all_variables variables
    end

    module ClassMethods

      # 注册渲染模板
      def register_render_template(template_name, *args)
        options = args.extract_options!
        section = options.slice(:only, :except)

        section[:name] = template_name
        self.content_templates << section
      end
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

    def load_all_variables(variables)
      variables.each do |variable|
        name = '@' + variable.name
        instance_variable_set name.to_sym, variable.exec if variable.respond_to?(:exec)
      end
    end

    def get_subject
      throw StandardError.new 'must have subject instance' if @subject.nil?
      @subject
    end

    def merge_variables(variables)
      variables.uniq { |var| var.name }
    end

    def valid_section?(section)
      name = action_name.to_sym

      if section[:only]
        section[:only].include? name
      elsif section[:except]
        !section[:except].include? name
      else
        true
      end
    end
  end
end
