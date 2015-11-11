class SubjectGenerator < Rails::Generators::NamedBase
  desc "This generator create subjects"

  source_root File.expand_path('../templates', __FILE__)

  attr_accessor :homepage_template, :index_template, :homepage_header_template, :footer_template, :promotion_template, :promotion_2col_template, :style_template, :subject

  def copy_subject_files
    check_subject

    self.homepage_template = "views/homepage.html.liquid"
    copy_file homepage_template, "#{subject_path}/views/homepage.html.liquid"

    self.index_template = "views/index.html.liquid"
    copy_file index_template, "#{subject_path}/views/index.html.liquid"

    self.homepage_header_template = "views/_homepage_header.html.liquid"
    copy_file homepage_header_template, "#{subject_path}/views/_homepage_header.html.liquid"

    self.footer_template = "views/_footer.html.liquid"
    copy_file footer_template, "#{subject_path}/views/_footer.html.liquid"
    
    self.promotion_template = "views/_promotion.html.liquid"
    copy_file promotion_template, "#{subject_path}/views/_promotion.html.liquid"

    self.promotion_2col_template = "views/_promotion_2col.html.liquid"
    copy_file promotion_2col_template, "#{subject_path}/views/_promotion_2col.html.liquid"

    self.style_template = "views/_style.html.liquid"
    copy_file style_template, "#{subject_path}/views/_style.html.liquid"

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
      subject.templates.create(name: 'index', filename: index_template, type: 'PageTemplate')
      subject.templates.create(name: 'footer', filename: footer_template, type: 'PageTemplate')
      subject.templates.create(name: 'promotion', filename: promotion_template, type: 'PageTemplate')
      subject.templates.create(name: 'promotion_2col_template', filename: promotion_2col_template, type: 'PageTemplate')
      subject.templates.create(name: 'homepage_header', filename: homepage_header_template, type: 'PageTemplate')
      subject.templates.create(name: 'style', filename: style_template, type: 'PageTemplate')
    end
end
