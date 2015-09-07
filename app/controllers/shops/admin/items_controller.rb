class Shops::Admin::ItemsController < Shops::Admin::BaseController

  def index
    @items = @shop.items
  end
end
