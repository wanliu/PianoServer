class ShopsController < ApplicationController

  def show_by_name
    @shop = Shop.find(params: { name: params[:shop_name]})

  end

  def show
    @shop = Shop.find(params[:id])
  end
end
