module RedirectCallback

  private

  def callback_url
    params[:callback] || session[:callback]
  end

  def set_callback
    session[:callback] = URI(request.referer).path if request.referer
  end

  def clear_callback
    session.delete(:callback)
  end
end