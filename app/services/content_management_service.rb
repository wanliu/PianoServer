module ContentManagementService
  extend self

  def update_template(template, content)
    file = template.send(:template_path)

    directory = File.dirname(file)
    FileUtils.mkdir_p directory unless File.directory?(directory)

    File.write file, content
    logger.info "\033[32mWriting\033[0m to #{file}..."
    logger.debug content
  end

  # def set_file_system(path)
  #   Liquid::Template.file_system = SubjectService::FileSystem.new(path, "_%s.html.liquid".freeze)
  # end

  def set_resource_file_system(resource, *args)
    resource_file_system(resource)
    set_file_system File.join(resource_file_system(resource), *args)
  end

  def resource_file_system(resource)
    pathname = resource.model_name.to_s.underscore.pluralize
    File.join root_path(resource), pathname, resource.name
  end

  def root_path(resource)
    resource.respond_to?(:root_path) ? resource.root_path : Settings.sites.root
  end

  module ContentController
    extend ActiveSupport::Concern

    included do |klass|
      include ContentManagementService::Helpers

      klass.class_attribute :content_templates
      attr_accessor :cached_all_templates
      attr_accessor :all_variables

      define_method :cached_all_templates do
        @cached_all_templates ||= {}
      end

      klass.content_templates = []
      before_action :check_subject_variables
    end

    def check_subject_variables
      unless @subject.nil?
        prepare_load_variables
        load_attachments
      end
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

      template_variables = merge_variables(load_variables)

      load_all_variables template_variables
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

    module ClassMethods

      # 注册渲染模板
      def register_render_template(template_name, *args)
        options = args.extract_options!
        section = options.slice(:only, :except)

        section[:name] = template_name
        self.content_templates << section
      end
    end

  end

  module Helpers
    VALID_VAR_NAME = /\A[_\p{letter}]+[\p{Alnum}_]*\z/

    def load_attachments
      @images = ImagesDrop.new(all_attachments)
      @attachments = all_attachments
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

  private
  def logger
    Rails.logger
  end
end
