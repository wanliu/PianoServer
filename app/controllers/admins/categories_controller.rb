class Admins::CategoriesController < Admins::BaseController

  before_action :get_industry

  def show
    # @industry.category.find()
    @category = Category.find(params[:id])
    @categories = @category.children
  end

  private

  def get_industry
    @industry = Industry.find(params[:industry_id])
  end
end
