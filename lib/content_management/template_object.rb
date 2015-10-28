module ContentManagement
  class TemplateObject
    def initialize(object, options = {})
      @object = object
      @default_prefix = options[:prefix] || "views"
      @root = options[:root] || ContentManagement::Config.options.root
    end

    def paths
      if @object.respond_to?(:content_paths)
        @object.content_paths
      elsif @object.respond_to?(:content_path)
        [ @object.content_path ]
      elsif @object.is_a? ActiveRecord::Base
        [ Rails.root.join(@root, class_tableize_name, instance_name) ]
      end
    end

    def view_name(name)
      template =
        if @object.respond_to?(:find_template)
          @object.find_template(name)
        elsif @object.respond_to?(:templates)
          @object.templates.find_by(name: name)
        end

      if template
        _normalize_path(template.filename)
      else
        name
      end
    end

    protected

    def extract_extname(filename)
      File.join(File.dirname(filename), File.basename(filename).split('.')[0])
    end

    def _normalize_path(filename)
      extract_extname(filename).sub /#{@default_prefix}\//, ''
    end

    def class_tableize_name
      @object.respond_to?(:class_tableize_name) ?
        @object.class_tableize_name : @object.class.name.tableize
    end

    def instance_name
      name = respond_method(:instance_name, :name)
      name ? @object.send(name) : @object.to_param
    end

    def respond_method(*args)
      args.find { |meth| @object.respond_to? meth }
    end

  end

  class PartialTemplateObject < TemplateObject

    protected

    def extract_extname(filename)
      firstname = File.basename(filename).split('.')[0]
      File.join(File.dirname(filename), firstname.sub(/^_/, ''))
    end
  end
end
