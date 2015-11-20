class IndustryController < ApplicationController

  def show
    @industry = Industry.find_by(name: params[:id])
  end
end
