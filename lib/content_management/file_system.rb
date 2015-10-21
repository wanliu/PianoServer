require 'liquid/file_system'

module ContentManagement
  class FileSystem < ::Liquid::LocalFileSystem
    def read_template_file(template_path, context)
      template_path   = "#{template_path}" unless template_path.include?('/')
      super
    end
  end
end
