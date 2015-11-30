module ApplicationHelper
  include SubjectsHelper
  include BootstrapHelper
  include AceEditorHelper
  include BindHelper
  include SearchHelper
  include WindowHelper
  include UploadHelper
  include Select2Helper
  include SettingsHelper
  include MinusPlusButtonHelper

  def avatar_url(user)
    user.image || identicon_url(user)
  end

  def default_image(type = :gray)
    image_path("#{type}_blank.gif")
  end

  def identicon_url(user, s = 50)
    md5 = Digest::MD5.new
    md5.update(user.email || user.username || user.mobile)
    md5.hexdigest
    "//www.gravatar.com/avatar/#{md5.hexdigest}?s=#{s}&default=identicon".html_safe
  end

  def nav_back_button
    content_for :back do
      raw '<li>' + link_to('javascript:history.back()') {
            icon :'chevron-left'
          } + '</li>'
    end
  end

  def nav_button(link)
    content_for :back do
      raw '<li>' + link_to(link) {
            icon :'chevron-left'
          } + '</li>'
    end
  end

  def link_to_void(name = nil, html_options = nil, &block)
    html_options = name if block_given?
    options = 'javascript:void(0)'

    if block_given?
      link_to options, html_options, &block
    else
      link_to name, options, html_options
    end
  end

  def avatar_image_tag(url, *args)
    image_tag url.blank? ? image_path('avatar.gif') : url, *args
  end

  def user_avatar(user, *args)
    options = args.extract_options!
    link_class = options[:class] ||= []
    link_class = link_class.is_a?(Array) ? link_class : [ link_class ]
    link_class.push 'nav-avatar'
    args.push options

    link_to user_profile_path(user), *args do
      avatar_image_tag(user.avatar_url) + " " + user.nickname + caret
    end
  end

  def cx(class_or_options, *args)
    html_class = ActiveSupport::HashWithIndifferentAccess.new

    case class_or_options
    when String
      class_or_options.split(' ').each { |cls| html_class[cls] = true }
      args.each { |cls| html_class[cls] = true }
    when Symbol
      args.unshift(class_or_options).each { |cls| html_class[cls] = true }
    when Hash
      class_or_options.each { |k, v| html_class[k] = v }
    end

    html_class.select {|k,v| v }.map { |k,v| k }.join(' ')
  end

  def bh_clear
    Bh::Classes::Stack.class_variable_get(:@@stack).clear
  end

  def set_module name
    content_for :module, name
  end

  def disable_navbar?
    content_for(:module) != "after_registers"
  end

  def phone_link(phone, title = nil, options = {}, &block)
    title, options = capture(&block), title if block_given?
    title = phone if title.nil?
    link_to title, 'tel:' + phone, options
  end

  def map_url(lat, lng, title, *args)
    options = args.extract_options! || {}
    content, src = args
    query = ::ActiveSupport::OrderedHash.new
    query = {
      location:  "#{lat},#{lng}",
      title: title,
      content: content || title,
      output: 'html',
      src: Settings.app.title,
      zoom: 15
    }

    provider_url = "http://api.map.baidu.com/marker"
    url = [provider_url, "#{to_query_without_sort(query)}"].join('?')
  end

  # def url_for(options)

  #   pp options
  #   case options
  #   when String
  #     if options.blank? or options == "/"
  #       "/"
  #     else
  #       options + ".html"
  #     end
  #   when Hash
  #     super options.merge({format: 'html'})
  #   else
  #     super
  #   end
  # end

  private

  def to_query_without_sort(obj, namespace = nil)
    obj.collect do |key, value|
      unless (value.is_a?(Hash) || value.is_a?(Array)) && value.empty?
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.compact * '&'
  end

  def user_profile_path(user)
    if user.id < 0
      '#'
    else
      profile_path(user.name)
    end
  end

  def s(*args)
    raw(*args)
  end

end
