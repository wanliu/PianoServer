class LocationsController < ApplicationController


  def new
    @location = Location.new(user_id: current_anonymous_or_user.id,
      chat_id: params[:chat_id], intention_id: params[:intention_id])
  end

  def show
    @user = User.find params[:user_id]
    @location = @user.locations
  end

  def create
    # location = current_anonymous_or_user.locations.build(location_params)
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        # render json: @location, status: :created
        #@intention = Intention.find(@location.intention_id)
        # @intention.delivery_location_id = @location.id
        #@intention.save
        format.json { render :show }
        format.html { redirect_to @location.chat_id ? chat_path(@location.chat_id) : location_path(@location) }
      else
        format.json { render json: { error: @location.errors.full_messages }, status: :unprocessable_entity }
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
      .permit(:province_id,:city_id,:region_id,:contact, :id, :road, :zipcode, :contact_phone, :user_id, :chat_id, :intention_id)
  end
end
