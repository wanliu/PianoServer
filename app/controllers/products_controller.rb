class ProductsController < ApplicationController

  def index
    @grid = ProductsGrid.new(params[:products_grid]) do |scope|
      scope.page(params[:page])
    end
  end

end

