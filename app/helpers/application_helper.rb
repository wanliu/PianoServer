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

  def nav_back_button(link = :back)
    content_for :back do 
      raw '<li>' + link_to(link) {
            icon :'chevron-left'
          } + '<li>'
    end
  end
end
