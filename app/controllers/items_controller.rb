class ItemsController < ShopsController
  # before_filter :set_shop
  before_filter :set_item, only: [ :show ]

  def index
    page = params[:page].presence || 1
    per = params[:per].presence || 8

  	@items = if params[:shop_id].present?
      Item.where(shop_id: params[:shop_id]).page(page).per(per)
  	elsif params[:shop_category_id].present?
      Item.where(shop_category_id: params[:shop_category_id]).page(page).per(per)
  	else
      []
    end
  end

  def show
    @item.punch(request)
    render :show, with: @item.category
    @current_user = current_anonymous_or_user
  end

  private
    def set_shop
      @shop = Shop.find_by(name: params[:shop_id])
    end

    def set_item
      @item = @shop.items.find_by_key(params)
    end
end
