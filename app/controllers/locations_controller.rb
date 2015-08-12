class LocationsController < ApplicationController


  def new
    @location = Location.new(chat_id: params[:chat_id] ,order_id: params[:order_id])
  end

  def create
    # location = current_anonymous_or_user.locations.build(location_params)
    @location = Location.new(location_params)


    if @location.save
      # render json: @location, status: :created
      @order = Order.find(@location.order_id)
      @order.delivery_location_id = @location.id
      @order.save
      
      redirect_to @location.chat_id ? chat_path(@location.chat_id) : location_path(@location)
    else
      render json: @location.errors, status: :unprocessable_entity
    end
  end

  def destroy
    location = Location.find params[:id]
  end

  private

  def location_params
    params.require(:location)
      .permit(:province_id,:city_id,:region_id,:contact, :id, :road, :zipcode, :contact_phone, :user_id, :chat_id, :order_id)
  end
end