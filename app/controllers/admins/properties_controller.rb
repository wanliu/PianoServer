class Admins::PropertiesController < Admins::BaseController
  # before_action :get_industry
  before_action :get_category
  before_action :get_property, only: [:show, :update, :destroy]

  def create

  end

  # def get_industry
  #   @industry = Industry.find(params[:industry_id])
  # end

  # def get_category
  #   @category = Category.find(params[:category_id])
  # end

  # def get_property
  #   @property = Property.find(params[:id])
  #   @container = params[:container]
  # end
end
