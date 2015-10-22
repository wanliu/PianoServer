# require 'active_support/concern'

module ContentManagement
  module ViewHelper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :render, :content
    end


    # 内容 render 系统, 我们使用 render 功能来输出模版，参数与 render 基础版本是一致的，我
    # 们仅增加了，with: 参数来声名渲染的对象是谁，With 是一个 Model 对象，
    # @param name_or_options String, Hash    Render 的参数
    # @param options = {} [type] [description]
    # @option options ActiveRecord::Base with  内容 Model 对象
    # @param &block [type] [description]
    #
    # @return [type] [description]
    def render_with_content(name_or_options, options = {}, &block)
      if name_or_options.is_a? Hash
        options = name_or_options
      else
        options[:partial] = name_or_options
      end

      template_class = options[:template_class] || PartialTemplateObject

      if with_object = options[:with]
        template_object = template_class.new(with_object)

        options[:partial] = options[:filename] || template_object.view_name(options[:partial])

        template_object.paths.each do |path|
          push_view_paths path
        end
      end

      render_without_content(options, &block)
    end

    protected

    def push_view_paths(path)
      self.lookup_context.view_paths.unshift path
    end

    def pop_view_paths()
      self.lookup_context.view_paths.shift
    end
  end
end
