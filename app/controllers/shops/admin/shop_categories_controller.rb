class Shops::Admin::ShopCategoriesController < Shops::Admin::BaseController
  before_action :is_descendant_of_category, only: [:show_by_child, :update_by_child, :upload_image, :destroy_by_child]

  def create
    @root = @shop.shop_category
    @shop_category = @root.children.create(shop_category_params)

    render :show, formats: [ :json ]
  end

  def create_by_child
    @root = @shop.shop_category
    @parent = ShopCategory.find(params[:parent_id])
    raise ActionController::RoutingError.new('Not Found') unless @parent.is_or_is_descendant_of?(@root)
    @shop_category = @parent.children.build(shop_category_params)

    if @shop_category.save
      render :show, formats: [ :json ]
    else
      render json: { errors: @shop_category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @shop_category = @shop.shop_category
    @root = @shop_category
  end

  def show_by_child
    render :show
  end

  def update_by_child
    @shop_category.update shop_category_params
    render :show, formats: [ :json ]
  end

  def destroy
    @root = @shop.shop_category
  end

  def destroy_by_child
    @shop_category.destroy
    render :destroy, formats: [:js]
  end

  def upload_image
    @shop_category.image = params[:file]
    @shop_category.save
    render json: { success: true, url: @shop_category.image.url(:cover) }
  end

  private

  def shop_category_params
    params.require(:shop_category).permit(:title)
  end

  def is_descendant_of_category
    @root = @shop.shop_category
    @shop_category = ShopCategory.find(params[:child_id])
    raise ActionController::RoutingError.new('Not Found') unless @shop_category.is_or_is_descendant_of?(@root)
  end
end
