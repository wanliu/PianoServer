class Api::ItemsController < Api::BaseController
  skip_before_action :authenticate_user!

  def search_ly
    @items = Item.search_leiyang_items(params)
      .page(params[:page])
      .per(params[:per])
      .records

    render json: { items: @items, page: @items.current_page, total_page: @items.total_pages }
  end
end