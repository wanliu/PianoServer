class SubjectGenerator < Rails::Generators::NamedBase
  desc "This generator create subjects"

  source_root File.expand_path('../templates', __FILE__)

  attr_accessor :index_template, :homepage_header, :subject

  def copy_subject_files
    check_subject

    self.index_template = "views/index.html.liquid"
    copy_file index_template, "#{subject_path}/views/index.html.liquid"

    self.homepage_header = "views/_homepage_header.html.liquid"
    copy_file homepage_header, "#{subject_path}/views/_homepage_header.html.liquid"

    bind_templates
  end

  private
    def check_subject
      self.subject = Subject.find_by(name: file_name)

      if subject.blank?
        raise Rails::Generators::Error.new("Invalid subject `#{file_name}`, Task failed!")
      end
    end

    def subject_root
      Settings.sites.system.root
    end
    
    def subject_path
      "#{subject_root}/subjects/#{file_name}"
    end

    def bind_templates
      subject.templates.create(name: 'index_template', filename: index_template, type: 'PageTemplate')
      subject.templates.create(name: 'homepage_header', filename: homepage_header, type: 'HomepageTemplate')
    end
end
