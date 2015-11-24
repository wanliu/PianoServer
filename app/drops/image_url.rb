module ImageUrl
  IMAGE_VERSIONS = %w(default icon avatar brand cover preview)
  extend ActiveSupport::Concern

  included do
    attr_accessor :image_object, :ignore_versions
  end

  def image_object
    @image_object ||= :image
  end

  def ignore_versions
    @ignore_versions ||= []
  end

  module ClassMethods
    def image_mount(image_object, options = {})
      @ignore_versions = options[:ignore_versions] ||= []
      @image_object = image_object
      url_method = options[:url_method] || :url

      define_method "#{image_object}_url" do
        object.send(image_object).send(url_method)
      end

      define_method "blank_image" do
        object.send(image_object).send(:blank_image?)
      end

      versions = IMAGE_VERSIONS - @ignore_versions
      versions.each do |version|
        define_method "#{version}_url" do
          object.send(image_object).send(url_method, version)
        end
      end
    end
  end
end
