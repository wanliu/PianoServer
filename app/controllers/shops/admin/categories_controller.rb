class Shops::Admin::CategoriesController < Shops::Admin::BaseController
  before_action :is_descendant_of_category, only: [:show_by_child, :update_by_child, :upload_image, :destroy_by_child]

  def create
    @root = @shop.categories.find(params[:parent_id])
    @category = @root.children.create(category_params)

    render :show, formats: [ :json ]
  end

  def create_by_child
    @root = @shop.categories.find_by(name: params[:id])
    @parent = Category.find(params[:parent_id])
    raise ActionController::RoutingError.new('Not Found') unless @parent.is_or_is_descendant_of?(@root)
    @category = @parent.children.create(category_params)

    render :show, formats: [ :json ]
  end

  def show
    @category = @shop.categories.where(name: params[:id]).first
    @root = @category
  end

  def show_by_child
    render :show
  end

  def update_by_child
    @category.update category_params
    render :show, formats: [ :json ]
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
    render json: { success: true, url: @category.image.url(:cover) }
  end

  private

  def category_params
    params.require(:category).permit(:title)
  end

  def is_descendant_of_category
    @root = @shop.categories.find_by(name: params[:id])
    @category = Category.find(params[:child_id])
    raise ActionController::RoutingError.new('Not Found') unless @category.is_or_is_descendant_of?(@root)
  end
end
