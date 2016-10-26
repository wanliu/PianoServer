class WechatCallbackController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :set_meta_user_data
  skip_before_action :current_subject
  skip_before_action :current_industry
  skip_before_action :set_current_cart
  skip_before_action :prepare_system_view_path
  skip_before_action :set_locale

  def redirect
    callback = params[:callback]

    if callback.include?('?')
      redirect_to "#{params[:callback]}&code=#{params[:code]}"
    else
      redirect_to "#{params[:callback]}?code=#{params[:code]}"
    end
  end
end
