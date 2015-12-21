# encoding: utf-8

IMAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES = %w(default icon avatar brand cover preview)
class ImageUploader < CarrierWave::Uploader::Base
  HTTP_PREFIX = /\Ahttp[s]?:\/\//
  include ActionView::Helpers::AssetUrlHelper
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :upyun
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
    asset_path('gray_blank.gif')
    # Settings.assets.gray_image
  end

  def url_with_version(version_name = "default")
    url_version(url_without_version, version_name)
  end

  def url_version(url, version = "default")
    version_name = version.to_s
    return url if version_name.blank?

    if not version_name.in?(IMAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES)
      # To protected version name using, when it not defined, this will be give an error message in development environment
      raise "ImageUploader version_name:#{version_name} not allow."
    end
    version_urls = version_name == "default" ? [url] : [url,version_name]
    blank_image? ? url : version_urls.join("!")
  end

  def blank_image?()
    url_without_version && url_without_version.end_with?(asset_path('gray_blank.gif'))
  end

  def url_with_absolute_path(*args)
    pure_image = self.path && self.path.is_a?(String) ? self.path.sub(/^#{self.store_path}/, '') : ''

    if absolute_url?(pure_image)
      if alliance_urls?(pure_image)
        url_version(pure_image, *args)
        # url_without_absolute_path(*args)
      else
        pure_image
      end
    else
      url_without_absolute_path(*args)
    end
  end
  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.

  def filename
    if super.present?
      @name ||="#{SecureRandom.hex}.#{file.extension.downcase}" if original_filename
      Rails.logger.debug("(BaseUploader.filename) #{@name}")
      @name
    end
  end

  private

  def asset_path(*args)
    ActionController::Base.helpers.asset_path *args
  end

  def absolute_url?(url)
    HTTP_PREFIX =~ url
  end

  def alliance_urls?(url)
    Settings.assets.alliance_hosts.any? {|host| url.start_with? host }
  end

  alias_method_chain :url, :version
  alias_method_chain :url, :absolute_path
end
