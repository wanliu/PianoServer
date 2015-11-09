class AfterRegistersController < ApplicationController
  before_action :set_type, only: [:show, :update]
  before_action :authenticate_user!

  def index
    redirect_to after_register_path(current_user.user_type) unless current_user.user_type.nil?
  end

  def show
    case @current_user.user_type
    when nil, "distributr"
      distributor_steps
    when "consumer"
      consumer_steps
    when "retail"
      retail_steps
    end
  end

  def update
    case @current_user.user_type
    when NilClass, "distributr"
      return render :show unless go_distributor_steps
    when "consumer"
      consumer_steps
    when "retail"
      retail_steps
    end

    @current_user.build_status state: params[:step]
    @current_user.user_type = @user_type.to_sym
    @current_user.save

    redirect_to after_register_path(@user_type)
  end

  def distributor_steps
    case @current_user.state
    when "select", nil
    when "industry"
      @shop = Shop.new(owner_id: @current_user.id)
    when "shop"
      @shop = Shop.new(owner_id: @current_user.id)
    when "category"
    when "brand"
      @brands = Brand.first(100)
    when NilClass
    else
    end
  end

  def go_distributor_steps
    case params[:step]
    when "select", NilClass
      true
    when "industry"
      true
    when "shop"
      @shop = Shop.create shop_params
      ShopService.build @shop.name
      return @shop.valid?
    when "category"
    when "brand"
    when NilClass
    else
    end
  end

  private

  def set_type
    @user_type = params[:id]
  end

  def shop_params
    params.require(:shop).permit(:title, :name, :phone, :description, :address, :owner_id)
  end
end
