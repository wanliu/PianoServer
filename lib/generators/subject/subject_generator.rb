class SubjectGenerator < Rails::Generators::NamedBase
  desc "This generator create subjects"

  source_root File.expand_path('../templates', __FILE__)

  def copy_subject_files
    copy_file 'views/index.html.liquid', "#{subject_path}/views/index.html.liquid"
    copy_file "views/_homepage_header.html.liquid", "#{subject_path}/views/_homepage_header.html.liquid"
  end

  private
    def subject_root
      Settings.sites.system.root
    end
    
    def subject_path
      "#{subject_root}/subjects/#{file_name}"
    end
end
