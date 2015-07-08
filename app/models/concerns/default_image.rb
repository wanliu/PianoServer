require_relative './gravatar_image_adapter'

module DefaultImage
  extend ActiveSupport::Concern


  included do |klass|
    cattr_accessor :image_resource_proc, 
                   :image_list_urls, 
                   :image_url_adapter,
                   :_image_options

    @@image_url_adapter = GravatarImageAdapter
    image_token :image
    image_list
    image_options
  end

  def image
    @image ||= OpenStruct.new super || image_urls_hash
  end

  def image_urls
    token = self.instance_exec &self.class.image_resource_proc
    self.class.image_list_urls.map do |k| 
      [ "#{k}_url", image_url_options(k, token) ]
    end.flatten
  end

  def image_urls_hash
    Hash.send(:[], *image_urls)
  end
  
  def image_url_options(image_type, token)
    default_image_url_adapter.image_url_options(image_type, token)
  end

  def default_image_url_adapter
    @default_image_url_adapter ||= self.class.image_url_adapter.new(self)
  end

  private 

  module ClassMethods
    def image_token(token_or_proc)
      self.image_resource_proc = if token_or_proc.is_a?(Proc)
                                token_or_proc
                              else
                                -> { send(token_or_proc) }
                              end
    end

    def image_list(list = [:avatar, :preivew]) 
      self.image_list_urls = list
    end

    def image_options(options = {})
      self._image_options = options
    end
  end
end
