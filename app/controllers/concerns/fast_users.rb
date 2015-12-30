module FastUsers
  def current_user
    if @current_user
      @current_user
    else
      if user = warden.authenticate(scope: :user)
        @current_user = user.attributes.deep_symbolize_keys
        @current_user[:image] = {}
        @current_user[:image][:url] = user.avatar_url
        @current_user
      elsif session[:anonymous]
        @current_user = anonymous(session[:anonymous])
      else
        id = (-Time.now.to_i + rand(10000))
        session[:anonymous] = id
        @current_user = anonymous(id)
      end
    end
  end

  def anonymous(id)
    {
      id: id,
      email: '',
      mobile: '',
      # created_at: Time.now,
      # updated_at: Time.now,
      image: {
        url: Settings.assets.avatar_image
      },
      nickname: "游客#{id.abs}",
      user_type: "consumer"
    }
  end

  def anonymous?
    current_user[:id] < 0
  end
end
