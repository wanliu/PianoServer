class ItemImageUploader < ImageUploader

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
  end
end
