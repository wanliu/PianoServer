module RedirectCallback

  def self.included(mod)
    mod.class_eval do
      helper_method :callback_url
    end
  end

  private

  def callback_url
    session[:callback] || root_path
  end

  def set_callback
    session[:callback] = params[:callback] or (request.referer &&  URI(request.referer).path)
  end

  def clear_callback
    Rails.logger.debug "callback url is #{session[:callback]}"
    session.delete(:callback)
  end
end
