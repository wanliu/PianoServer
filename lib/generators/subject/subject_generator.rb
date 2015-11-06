class SubjectGenerator < Rails::Generators::NamedBase
  desc "This generator create subjects"

  source_root File.expand_path('../templates', __FILE__)

  attr_accessor :index_template, :footer_template, :homepage_header, :homepage_template, :promotion_template, :subject

  def copy_subject_files
    check_subject

    self.homepage_template = "views/homepage.html.liquid"
    copy_file homepage_template, "#{subject_path}/views/homepage.html.liquid"

    self.index_template = "views/index.html.liquid"
    copy_file index_template, "#{subject_path}/views/index.html.liquid"

    self.promotion_template = "views/_promotion.html.liquid"
    copy_file promotion_template, "#{subject_path}/views/_promotion.html.liquid"

    self.homepage_header = "views/_homepage_header.html.liquid"
    copy_file homepage_header, "#{subject_path}/views/_homepage_header.html.liquid"

    self.footer_template = "views/_footer.html.liquid"
    copy_file footer_template, "#{subject_path}/views/_footer.html.liquid"


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
      SubjectService.subject_root
    end

    def subject_path
      "#{subject_root}/#{file_name}"
    end

    def bind_templates
      subject.templates.create(name: 'homepage', filename: homepage_template, type: 'PageTemplate')
      subject.templates.create(name: 'footer', filename: footer_template, type: 'PageTemplate')
      subject.templates.create(name: 'index', filename: index_template, type: 'PageTemplate')
      subject.templates.create(name: 'promotion', filename: promotion_template, type: 'PartialTemplate')
      subject.templates.create(name: 'homepage_header', filename: homepage_header, type: 'HomepageTemplate')
    end
end
