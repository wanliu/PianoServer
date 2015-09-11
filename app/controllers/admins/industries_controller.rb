class Admins::IndustriesController < Admins::BaseController
  before_action :get_industry, only: [:edit, :udpate, :show]
  def new
    @industry = Industry.new
  end

  def index
    @industries = Industry.all
  end

  def create
    @industry = Industry.create industry_params
    redirect_to edit_admins_industry_path(@industry)
  end

  def edit

  end

  private

  def industry_params
    params.require(:industry).permit(:name, :title, :description)
  end

  def get_industry
    @industry = Industry.find(params[:id])
  end
end
