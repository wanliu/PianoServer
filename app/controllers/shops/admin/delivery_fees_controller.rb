class Shops::Admin::DeliveryFeesController < Shops::Admin::BaseController
  def show
    @delivery_fee_settings = @shop.item_delivery_fee
    @delivery_fee_settings.each do |code, fee|
      @delivery_fee_settings[code] = {
        fee: fee, 
        title: get_code_title(code)
      }
    end
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
        title: get_code_title(params[:code]),
        fee: params[:fee]
      }, status: :created
    end
  end

  def next_nodes
    list = ChinaCity.list(params[:code])
    render json: list
  end

  def update
    @shop.item_delivery_fee[params[:code]] = params[:fee].to_f
    @shop.save

    render json: {code: params[:code], fee: @shop.item_delivery_fee[params[:code]]}
  end

  def destroy
    @shop.item_delivery_fee.delete params[:code]
    @shop.save

    head :no_content
  end

  private

  def get_code_title(code)
    if "default" == code
      "默认"
    else
      title = ChinaCity.get(code)

      unless code == ChinaCity.city(code)
        title = ChinaCity.get(ChinaCity.city(code)) + title
      end

      unless code == ChinaCity.province(code)
        title = ChinaCity.get(ChinaCity.province(code)) + title
      end

      title
    end
  end
end