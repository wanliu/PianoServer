class Admins::BrandsController < Admins::BaseController

  def index
    @brands = Brand.all
  end
end
