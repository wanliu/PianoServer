module RedirectCallback

  private

  def callback_url
    session[:callback] || root_path
  end

  def set_callback
    session[:callback] = request.referer &&  URI(request.referer).path or params[:callback]
  end

  def clear_callback
    session.delete(:callback)
  end
end
