
class AvatarUploader < ImageUploader
  def default_url
    Settings.assets.avatar_image
  end

end
