module RedirectCallback

  private

  def callback_url
    params[:callback] || session[:callback]
  end

  def set_callback
    session[:callback] = URI(request.referer).path if request.referer
    Rails.logger.debug "callback url is #{session[:callback]}"
  end

  def clear_callback
    Rails.logger.debug "callback url is #{session[:callback]}"
    session.delete(:callback)
  end
end
