# like RedirectCallback, but callback not store in session,
# just in query params

module ParamsCallback

  def self.included(mod)
    mod.class_eval do
      helper_method :callback_url
    end
  end

  private

  def callback_url
    params[:callback]
  end
end
