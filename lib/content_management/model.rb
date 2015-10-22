module ContentManagement
  module Model

    def class_tableize_name
      self.class.name.tableize
    end

    def instance_name
      respond_to?(name) ? name : to_param
    end

    def content_path

      File.join content_root, instance_name
    end

    def content_root
      File.join Rails.root, Settings.sites.root, class_tableize_name
    end
  end
end
