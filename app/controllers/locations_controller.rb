class LocationsController < ApplicationController


  def new
    @location = Location.new(user_id: current_anonymous_or_user.id)
  end

  def show
    @user = User.find params[:user_id]
    @location = @user.locations
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
      respond_to do |format|
        format.json { render json: @location.errors, status: :unprocessable_entity }
        format.html { render :new }
      end
    end
  end

  def destroy
    location = Location.find params[:id]
  end

  def user_default_address
    @user = User.find params[:user_id];
    @user.latest_location_id = params[:location_id];
    @user.save

    render json: @user.latest_location
  end

  private

  def location_params
    params.require(:location)
      .permit(:province_id,:city_id,:region_id,:contact, :id, :road, :zipcode, :contact_phone, :user_id, :chat_id, :order_id)
  end
end
