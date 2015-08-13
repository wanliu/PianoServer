class ItemsController < ApplicationController
  def index
    page = params[:page].presence || 1
    per = params[:per].presence || 8

  	@items = if params[:shop_id].present?
      Item.where(shop_id: params[:shop_id]).page(page).per(per)
  	elsif params[:shop_category_id].present?
      Item.where(shop_category_id: params[:shop_category_id).page(page).per(per)
  	else
      []
    end
  end

  def show
    @item = Item.find(params[:id])
    @shop = @item.shop
  end
end
