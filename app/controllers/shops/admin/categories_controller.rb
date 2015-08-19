class Shops::Admin::CategoriesController < Shops::Admin::BaseController
  before_action :get_shop

  def create
    @root = @shop.categories.find(params[:parent_id])
    @category = @root.children.create(category_params)
    @shop.categories << @category

    render :show, formats: [ :json ]
  end

  def create_by_child
    @root = @shop.categories.find(params[:id])
    @parent = Category.find(params[:parent_id])
    raise ActionController::RoutingError.new('Not Found') unless @parent.is_or_is_descendant_of?(@root)
    @category = @parent.children.create(category_params)
    @shop.categories << @category

    render :show, formats: [ :json ]
  end

  def show
    @category = @shop.categories.where(id: params[:id]).first
    @root = @category
  end

  def show_by_child
    @root = @shop.categories.find(params[:id])
    @category = Category.find(params[:child_id])
    raise ActionController::RoutingError.new('Not Found') unless @category.is_descendant_of?(@root)
    render :show
  end

  def get_shop
    @shop = Shop.find_by name: params[:shop_id]
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
