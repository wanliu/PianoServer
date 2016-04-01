class Shops::Admin::DeliveryFeesController < Shops::Admin::BaseController
  include DeliveryAreaTitle

  before_action :set_object

  def show
    delivery_fee_settings.each do |code, fee|
      delivery_fee_settings[code] = {
        fee: fee, 
        title: get_code_title(code)
      }
    end
  end

  def create
    if delivery_fee_settings[params[:code]].present?
      render json: {
        error: "#{get_code_title(params[:code])}地区的运费已经设置，无需再次设置"
      }, status: :unprocessable_entity
    else
      delivery_fee_settings[params[:code]] = params[:fee].to_f
      @object.save

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
    delivery_fee_settings[params[:code]] = params[:fee].to_f
    @object.save

    render json: {code: params[:code], fee: delivery_fee_settings[params[:code]]}
  end

  def destroy
    delivery_fee_settings.delete params[:code]
    @object.save

    head :no_content
  end

  private

  def set_object
    @object = if "item" == params[:objective]
      params[:id] = params[:item_id]
      @shop.items.find_by_key(params)
    else
      @shop
    end
  end

  def delivery_fee_settings(reload=false)
    if reload
      @delivery_fee_settings = if "item" == params[:objective]
        @object.delivery_fee
      else
        @object.item_delivery_fee
      end
    else
      @delivery_fee_settings ||= if "item" == params[:objective]
        @object.delivery_fee
      else
        @object.item_delivery_fee
      end
    end
  end
end