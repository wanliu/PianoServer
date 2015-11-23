class IndustryController < ApplicationController
  before_action :authenticate_region!

  def show
    @industry = Industry.find_by(name: params[:id])
    render :show, with: @industry
  end

end
