class Admins::ProductsController < Admins::BaseController

  def index
    # @grid = ProductsGrid.new(params[:products_grid]) do |scope|
    #   # scope.page(params[:page])
    # end
    @products = Product.search(size: 100, from: params[:page]).results
  end
end
