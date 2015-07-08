class GravatarImageAdapter

  attr_accessor :target

  def initialize(target)
    @target = target
  end

  def image_url_options(image_type, token)
    options = target.class._image_options || {}
    params = []
    case image_type
    when :avatar
      params.push(options_size_url(options))
      params.push(options_identicon_url(options))      
    when :preview
      params.push(options_identicon_url(options))
    end
    [default_image_url(token), params.join('&')].join('?')    
  end

  def default_image_url(token)
    md5 = Digest::MD5.new
    md5.update(token)
    md5.hexdigest
    "//www.gravatar.com/avatar/#{md5.hexdigest}"
  end

  def options_size_url(options)
    s = options[:s] || 50
    "s=#{s}"
  end

  def options_identicon_url(options) 
    options[:default] ||= 'identicon'
    "default=#{options[:default]}"
  end  
end
