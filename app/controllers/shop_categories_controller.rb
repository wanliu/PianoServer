class ShopCategoriesController < ShopsController

  before_action :set_shop_category, only: [ :show ]
  # caches_page :index, :show

  def index
    @shop_categories = @shop.shop_category.children.where(status: true).page(params[:page]).per(params[:per])
  end

  def show
    add_page_title t("titles.shop_category", category: @shop_category.title)

    @shop_category.punch(request)

    @current_user = current_anonymous_or_user

    if @shop_category.has_children
      @shop_categories = ShopCategory.where(parent_id: @shop_category, status: true).order(id: :asc)
      @items = []
    else
      @items = Item.where(abandom: false, on_sale: true, shop_category_id: params[:id]).order(id: :desc)
      @shop_categories = []
    end
  end

  private

  def set_shop
    @shop = Shop.find_by(name: params[:shop_id])
    @shop.punch(request)
  end

  def set_shop_category
    @root = @shop.shop_category
    @shop_category = ShopCategory.find(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless @shop_category.is_or_is_descendant_of?(@root)
  end
end
