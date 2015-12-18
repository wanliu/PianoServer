class SmartFillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content_for

  def index
    redirect_to smart_fills_path(current_user.user_type) unless current_user.state.nil
  end

  def show

  end

  private
  def set_content_for
    content_for :module, :smart_fills
  end
end
