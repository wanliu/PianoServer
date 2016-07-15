class Api::Promotions::VirtualPresentsController < Api::BaseController
  skip_before_action :authenticate_user!

  def index
    @virtual_presents = VirtualPresent.order(price: :asc)
      .page(params[:page])
      .per(params[:per])

    render json: {
      virtual_presents: @virtual_presents,
      page: @virtual_presents.current_page,
      total_page: @virtual_presents.total_pages
    }
  end

  def existPresent
    virtual_present = VirtualPresent.find_by(name: params[:name]);
    isExist = virtual_present.present?

    render json: { isExist: isExist }
  end
end
