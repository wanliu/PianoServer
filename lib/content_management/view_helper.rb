# require 'active_support/concern'

module ContentManagement
  module ViewHelper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :render, :content
    end

    def render_with_content(name_or_options, options = {}, &block)
      pp self.lookup_context.class
      if name_or_options.is_a? Hash
        options = name_or_options
      else
        options[:partial] = name_or_options
      end

      if with_object = options[:with]
        push_view_paths with_object.content_path
      end

      # if tpl.nil?
      #   render options
      # elsif is_partial?(tpl.filename)
      #   set_file_system subject
      #   path = File.join("subjects", subject.name, tpl.filename.sub(/^views\/_/, 'views/'))
      #   set_file_system subject
      #   render({ partial: path }.reverse_merge(options))
      # else
      #   set_file_system subject
      #   path = File.join("subjects", subject.name, tpl.filename)
      #   render path
      # end

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
