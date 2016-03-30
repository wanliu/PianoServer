class Shops::Admin::DeliveryFeesController < Shops::Admin::BaseController
  def show
    @delivery_fee_settings = @shop.item_delivery_fee
  end

  def create
    delivery_fee_settings = @shop.item_delivery_fee

    if delivery_fee_settings[params[:code]].present?
      render json: {
        error: "#{ChinaCity.get(params[:code])}地区的运费已经设置，无需再次设置"
      }, status: :unprocessable_entity
    else
      @shop.item_delivery_fee[params[:code]] = params[:fee].to_f
      @shop.save
      render json: {
        code: params[:code], 
        title: ChinaCity.get(params[:code]),
        fee: params[:fee].to_f
      }, status: :created
    end
  end

  def next_nodes
    list = ChinaCity.list(params[:code])
    render json: list
  end
end