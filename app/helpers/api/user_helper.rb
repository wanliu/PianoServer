module Api::UserHelper
  require 'digest'

  # private 

  def avatar_url(user)
    user.image || identicon_url(user)
  end

  def identicon_url(user, s = 50)
    md5 = Digest::MD5.new
    md5.update(user.email || user.username || user.mobile)
    md5.hexdigest
    "//www.gravatar.com/avatar/#{md5.hexdigest}?s=#{s}&default=identicon".html_safe
  end  
end
