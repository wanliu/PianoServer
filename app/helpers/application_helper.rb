module ApplicationHelper

  def avatar_url(user)
    user.image || identicon_url(user)
  end

  def identicon_url(user, s = 50)
    md5 = Digest::MD5.new
    md5.update(user.email || user.username || user.mobile)
    md5.hexdigest
    "//www.gravatar.com/avatar/#{md5.hexdigest}?s=#{s}&default=identicon".html_safe
  end

  def bootstrap_flash
    flash_class = {
      'notice' => 'success',
      'alert' => 'warning',
      'error' => 'danger'
    }

    flash.map do |k, title|
      <<-HTML
        <div class="alert alert-#{flash_class[k]}" role="alert">#{title}</div>
      HTML
    end.join('').html_safe
  end

  def icon(name)
    raw "<span class=\"button-icon glyphicon glyphicon-#{name}\"></span>"
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
      avatar_image_tag(user.avatar_url) + user.nickname + caret
    end
  end

  def caret
    raw "<span class=\"caret\"></span>"
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

  private

  def user_profile_path(user)
    if user.id < 0
      '#'
    else
      profile_path(user)
    end
  end

end
