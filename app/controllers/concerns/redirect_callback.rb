module RedirectCallback

  def self.included(mod)
    mod.class_eval do
      helper_method :callback_url
    end
  end

  private

  def callback_url
    url = session[:callback] || root_path
    if url.include("?")
      url + "&t=#{Time.now.to_i}"
    else
      url + "?t=#{Time.now.to_i}"
    end
  end

  def set_callback
    session[:callback] = params[:callback] or (request.referer &&  URI(request.referer).path)
    session[:goto_one_money] = params[:goto_one_money] == 'true'
    session[:goto_leiyangstreet] = params[:goto_leiyangstreet] == 'true'
  end

  def clear_callback
    Rails.logger.debug "callback url is #{session[:callback]}"
    session.delete(:callback)
    session.delete(:goto_one_money)
    session.delete(:goto_leiyangstreet)
  end
end
