
module ContentManagement
  module ViewHelper
    include Paths

    # 内容 render 系统, 我们使用 render 功能来输出模版，参数与 render 基础版本是一致的，我
    # 们仅增加了，with: 参数来声名渲染的对象是谁，With 是一个 Model 对象，
    # @param name_or_options String, Hash    Render 的参数
    # @param options = {} [type] [description]
    # @option options ActiveRecord::Base with  内容 Model 对象
    # @param &block [type] [description]
    #
    # @return [type] [description]
    def render(name_or_options, options = {}, &block)
      if name_or_options.is_a? Hash
        options = name_or_options
      else
        options[:partial] = name_or_options
      end

      template_class = options[:template_class] || PartialTemplateObject

      if with_object = options[:with]
        template_object = template_class.new(with_object, options[:partial])
        # self.assigns["templable_object"] = template_object

        name, type = template_object.view_name
        if type == :file && options[:collection]
          options[:partial] = template_object.send(:_normalize_path, name)
        elsif type == :file
          options[:file] = File.join(template_object.path, name)
          options.delete(:partial)
        else
          options[:partial] = name
        end

        options[:template_object] = template_object.template

        # options[:partial] = options[:filename] || template_object.view_name(options[:partial])
        template_object.paths.each do |path|
          push_view_paths path
        end
        options.delete(:with)
      end
      super(options, &block)
    end

    def render_collection(*args)
      super
    end
  end
end
