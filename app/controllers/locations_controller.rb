class LocationsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :create, :udpate, :destroy, :user_default_address]
  before_action :set_location, only: [:edit, :update, :destroy]

  def index
    @locations = current_user.locations.order(id: :desc)
  end

  def new
    @location = Location.new(user_id: current_anonymous_or_user.id,
      chat_id: params[:chat_id], intention_id: params[:intention_id])
  end

  def edit
  end

  def show
    @user = User.find params[:user_id]
    @location = @user.locations
  end

  def create
    # location = current_anonymous_or_user.locations.build(location_params)
    @location = current_user.locations.build(location_params)

    respond_to do |format|
      if @location.save
        # render json: @location, status: :created
        #@intention = Intention.find(@location.intention_id)
        # @intention.delivery_location_id = @location.id
        #@intention.save
        format.json { render :show }
        format.html do
          flash[:notice] = "收货地址创建成功"
          direction = @location.chat_id.present? ? chat_path(@location.chat_id) : locations_path
          redirect_to direction
        end
      else
        format.json { render :new, formats: :html, layout: false, status: :unprocessable_entity }
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @location.update(location_update_params)
        format.json { render json: @location, status: :ok }
        format.html do
          flash[:notice] = "收货地址保存成功"
          redirect_to locations_path
        end
      else
        format.json { render json: {error: @location.errors} }
        format.html { render :edit }
      end
    end
  end

  def destroy
    @location.destroy

    flash[:notice] = "收货地址删除成功"
    redirect_to locations_path
  end

  def user_default_address
    @location = current_user.locations.find(params[:location_id])
    current_user.update_attribute('latest_location_id', @location.id)

    respond_to do |format|
      format.json { render json: @location }
      format.html { redirect_to locations_path }
    end
  end

  private

  def location_params
    params.require(:location)
      .permit(:province_id, :city_id, :region_id, :contact, :id, :road, :zipcode, :contact_phone, :chat_id, :intention_id)
  end

  def location_update_params
    params.require(:location)
      .permit(:province_id, :city_id, :region_id, :contact, :id, :road, :zipcode, :contact_phone, :is_default)
  end

  def set_location
    @location = current_user.locations.find(params[:id])
  end
end
