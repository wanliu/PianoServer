class Shops::Admin::ItemsController < Shops::Admin::BaseController

  def index
    @items = Item.with_shop(@shop.id)
                 .with_category(query_params[:category_id])
                 .with_query(query_params[:q])
                 .page(query_params[:page])

    @categories = shop_category_root.children
  end


  protected

  def query_params
    params.permit(:shop_id, :category_id, :q, :page)
  end

  def shop_category_root
    @category_root ||= @shop.categories.find_by(name: "product_category")
  end
end
