class AfterRegistersController < ApplicationController
  before_action :set_type, only: [:show, :update]
  def update
    current_user.user_type = @user_type.to_sym
    current_user.save
    render :show
  end

  private

  def set_type
    @user_type = params[:id]
  end
end
