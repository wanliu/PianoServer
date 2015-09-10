class Admins::ProductsController < Admins::BaseController

  def index
    @properties = Property.all
  end
end
