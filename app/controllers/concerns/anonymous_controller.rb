module AnonymousController

  protected

  def current_anonymous_or_user
    @current_user ||= current_user
    @current_user || anonymous
  end

  def anonymous
    if session[:anonymous]
      @anonymous = User.anonymous(session[:anonymous])
    else
      @anonymous = User.anonymous
      session[:anonymous] = @anonymous.id
    end
    @anonymous
  end

  def anonymous?
    current_anonymous_or_user.id < 0
  end
end
