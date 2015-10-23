module ContentManagement
  module Paths

    protected

    def push_view_paths(path)
      push_paths File.join(path, Config.options.views_prefix)
    end

    def push_paths(path)
      self.lookup_context.view_paths.unshift path
    end

    def pop_view_paths()
      self.lookup_context.view_paths.shift
    end
  end
end
