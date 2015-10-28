module ContentManagement
  module Utils
    extend self

    def set_file_system(path)
      Liquid::Template.file_system = ::Liquid::LocalFileSystem.new(path, "_%s.html.liquid".freeze)
    end

    def set_resource_file_system(resource, *args)
      resource_file_system(resource)
      set_file_system File.join(resource_file_system(resource), *args)
    end

    def resource_file_system(resource)
      pathname = resource.model_name.to_s.underscore.pluralize
      File.join root_path(resource), pathname, resource.name
    end

    private

    def root_path(resource)
      resource.respond_to?(:root_path) ? resource.root_path : Settings.sites.root
    end
  end
end
