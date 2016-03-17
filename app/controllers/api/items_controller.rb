class Api::ItemsController < Api::BaseController
  skip_before_action :authenticate_user!

  def search_ly
    @items = Item.search_leiyang_items(params)
      .page(params[:page])
      .per(params[:per])
      .records

    if params[:q].present? && @items.count > 0
      suggestion = Suggestion.find_by(title: params[:q])
      if suggestion.present?
        suggestion.increment!(:count)
      else
        Suggestion.create(title: params[:q], count: 1)
      end
    end

    render json: { items: @items, page: @items.current_page, total_page: @items.total_pages }
  end
end