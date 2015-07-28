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
    link_to user_profile_path(user), { class: 'nav-avatar' } do
      avatar_image_tag(user.avatar_url, *args) + user.nickname
    end
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
