class Admins::ProductsController < Admins::BaseController

  def index
    @properties = Property.order(id: :asc).page(params[:page]).per(params[:per])
  end
end
