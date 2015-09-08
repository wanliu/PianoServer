class Shops::Admin::ItemsController < Shops::Admin::BaseController
  def load_categories
    page = params[:page].presence || 1
    per = params[:per].presence || 25

    if params[:category_id].present?
      @categories = Category.where(parent_id: params[:category_id])
      @items = Item.where(shop_category_id: params[:category_id]).page(page).per(per)
    else
      @root = @shop.categories.first
      @categories = Category.where(parent_id: @root.id)
      @items = Item.where(shop_id: @shop.id).page(page).per(per)
    end

    render json: {categories: @categories.as_json(methods: [:is_leaf]), items: @items }
  end
end
