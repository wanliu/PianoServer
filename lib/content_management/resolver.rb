module ContentManagement
  module Resolver
    extend ActiveSupport::Concern

    included do |klass|

      alias_method_chain :cached, :template
    end

  private

    def cached_with_template(key, path_info, details, locals) #:nodoc:
      name, prefix, partial = path_info
      locals = locals.map { |x| x.to_s }.sort!

      if details[:template_object]
        locals.push(details[:template_object])
      end

      if key
        @cache.cache(key, name, prefix, partial, locals) do
          locals.pop if details[:template_object]
          decorate(yield, path_info, details, locals)
        end
      else
        decorate(yield, path_info, details, locals)
      end
    end
  end
end
