class ShopCategoriesController < ShopsController
  before_filter :set_shop_category, only: [ :show ]

  def index
    @shop_categories = @shop.shop_category.children.page(params[:page]).per(params[:per])
  end

  def show
    add_page_title t("titles.shop_category", category: @shop_category.title)

    if @shop_category.has_children
      @shop_categories = ShopCategory.where(parent_id: @shop_category).order(id: :asc).page(params[:page]).per(params[:per])
      @items = []
    else
      @items = Item.where(shop_category_id: params[:id]).page(params[:page]).per(params[:per])
      @shop_categories = []
    end
  end

  private
    def set_shop
      @shop = Shop.find_by(name: params[:shop_id])
    end

    def set_shop_category
      @shop_category = ShopCategory.find(params[:id])
      @root = @shop.shop_category
    end
end
