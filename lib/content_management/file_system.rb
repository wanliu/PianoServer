require 'liquid/file_system'

module ContentManagement
  class FileSystem < ::Liquid::LocalFileSystem
    def read_template_file(template_path, context)
      view = context.registers[:view]
      paths = view.view_paths.map(&:to_s)
      template_path  = "#{template_path}" unless template_path.include?('/')

      path = paths.find do |path|
        File.exist?(full_path(template_path, path))
      end

      filename = full_path(template_path, path)
      raise FileSystemError, "No such template '#{template_path}'" unless filename

      File.read(filename)
    end


    def full_path(template_path, root)
      raise FileSystemError, "Illegal template name '#{template_path}'" unless template_path =~ /\A[^.\/][a-zA-Z0-9_\/]+\z/

      full_path = if template_path.include?('/'.freeze)
        File.join(root, File.dirname(template_path), @pattern % File.basename(template_path))
      else
        File.join(root, @pattern % template_path)
      end

      raise FileSystemError, "Illegal template path '#{File.expand_path(full_path)}'" unless File.expand_path(full_path) =~ /\A#{File.expand_path(root)}/

      full_path
    end
  end
end
