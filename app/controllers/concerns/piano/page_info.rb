module Piano
  module PageInfo
    extend ActiveSupport::Concern
    include RenderCallbacks

    included do |app_klass|
      app_klass.class_attribute :page_title
      app_klass.class_attribute :page_navbar
      app_klass.class_attribute :page_navbar_link

      app_klass.page_title = []
      app_klass.page_navbar = Settings.app.name
      app_klass.page_navbar_link = "/"

      before_render :prepare_page_title
      before_render :prepare_page_navbar
    end

    def page_prefix
      "titles."
    end

    def set_page_title(*titles)
      self.page_title = titles
      @title = ''
    end


    def add_page_title(*titles)
      self.page_title += titles
      @title = ''
    end

    private

    def page_pair_name(pair, name)
      t( "#{page_prefix}.#{pair}.#{name}",
        default: [ :"#{pair}.#{name}", name ] )
    end

    def prepare_page_title
      self.page_title +=
        if @title.nil?
          [ page_pair_name(:controllers, controller_name),
            page_pair_name(:actions, action_name) ]
        else
          [ @title ]
        end.reject { |c| c.empty? }

      # set_meta_tags title: self.page_title.reverse.join(' ').humanize
    end

    def prepare_page_navbar
      content_for :navbar, self.page_navbar.humanize
      content_for :navbar_link, self.page_navbar_link
    end
  end
end
