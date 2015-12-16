module ContentManagement
  module Resolver
    extend ActiveSupport::Concern

    included do |klass|

      alias_method_chain :cached, :template
    end

  private

    # 利用 ActionView::Resolver 自身的缓存机制来进行缓存，在 options 压入 template_object
    # 后，在 locals 中生成一个临时变量使缓存工作
    def cached_with_template(key, path_info, details, locals) #:nodoc:
      name, prefix, partial = path_info
      locals = locals.map { |x| x.to_s }.sort!

      unless details[:template_object].blank?
        locals.push(details[:template_object])
      end

      if key
        @cache.cache(key, name, prefix, partial, locals) do
          locals.pop unless details[:template_object].blank?
          decorate(yield, path_info, details, locals)
        end
      else
        decorate(yield, path_info, details, locals)
      end
    end
  end
end
