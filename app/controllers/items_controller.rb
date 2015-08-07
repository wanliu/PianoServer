class ItemsController < ApplicationController
  def index
  end

  def show
    @item = Item.find(params[:id])
    @shop = Shop.find(@item.shop_id)
  end
end
