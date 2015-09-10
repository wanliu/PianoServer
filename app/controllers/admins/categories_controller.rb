class Admins::CategoriesController < Admins::BaseController

  before_action :get_industry
  before_action :get_category, only: [:show, :properties]

  def show
    # @industry.category.find()
    @categories = @category.children
  end

  def properties
    @properties = @category.properties
  end

  def category_edit

  end

  private

  def get_industry
    @industry = Industry.find(params[:industry_id])
  end

  def get_category
    @category = Category.find(params[:id])
  end
end
