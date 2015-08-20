class Shops::Admin::CategoriesController < Shops::Admin::BaseController
  before_action :get_shop
  before_action :is_descendant_of_category, only: [:show_by_child, :update_by_child, :upload_image, :destroy_by_child]

  def create
    @root = @shop.categories.find(params[:parent_id])
    @category = @root.children.create(category_params)

    render :show, formats: [ :json ]
  end

  def create_by_child
    @root = @shop.categories.find(params[:id])
    @parent = Category.find(params[:parent_id])
    raise ActionController::RoutingError.new('Not Found') unless @parent.is_or_is_descendant_of?(@root)
    @category = @parent.children.create(category_params)
    render :show, formats: [ :json ]
  end

  def show
    @category = @shop.categories.where(id: params[:id]).first
    @root = @category
  end

  def show_by_child
    render :show
  end

  def update_by_child
    @category.update category_params
    render :show, formats: [ :json ]
  end

  def get_shop
    @shop = Shop.find_by name: params[:shop_id]
  end

  def destroy
    @root = @shop.categories.find(params[:id])
  end

  def destroy_by_child
    @category.destroy
    render :destroy, formats: [:js]
  end

  def upload_image
    @category.image = params[:file]
    @category.save
    @category.reload
    pp @category
    render json: { success: true, url: @category.image.url }
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def is_descendant_of_category
    @root = @shop.categories.find(params[:id])
    @category = Category.find(params[:child_id])
    raise ActionController::RoutingError.new('Not Found') unless @category.is_or_is_descendant_of?(@root)
  end
end
