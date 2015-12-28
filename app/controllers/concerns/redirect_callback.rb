module RedirectCallback

  private

  def callback_url
    session[:callback] || stored_location_for(:user) || root_path
  end

  def set_callback
    session[:callback] = params[:callback] or (request.referer &&  URI(request.referer).path)
  end

  def clear_callback
    Rails.logger.debug "callback url is #{session[:callback]}"
    session.delete(:callback)
  end
end
