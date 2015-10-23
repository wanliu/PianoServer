module ContentPath

  def content_path
    File.join content_root, name
  end

  def content_root
    File.join Rails.root, Settings.sites.root, self.model_name.to_s.underscore.pluralize
  end
end
