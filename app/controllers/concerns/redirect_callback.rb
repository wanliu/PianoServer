module RedirectCallback

  private

  def callback_url
    session[:callback] || root_path
  end

  def set_callback
    session[:callback] = params[:callback] or (request.referer &&  URI(request.referer).path)
    session[:goto_one_money] = params[:goto_one_money] == 'true'
  end

  def clear_callback
    Rails.logger.debug "callback url is #{session[:callback]}"
    session.delete(:callback)
    session.delete(:goto_one_money)
  end
end
