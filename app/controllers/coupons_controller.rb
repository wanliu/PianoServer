class CouponsController < ApplicationController
  before_action :set_coupon, only: [:show, :update, :destroy]

  # GET /coupons
  # GET /coupons.json
  def index
    @coupons = Coupon.all

    render json: @coupons
  end

  # GET /coupons/1
  # GET /coupons/1.json
  def show
    render json: @coupon
  end

  # POST /coupons
  # POST /coupons.json
  def create
    @coupon = Coupon.new(coupon_params)

    if @coupon.save
      render json: @coupon, status: :created, location: @coupon
    else
      render json: @coupon.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /coupons/1
  # PATCH/PUT /coupons/1.json
  def update
    @coupon = Coupon.find(params[:id])

    if @coupon.update(coupon_params)
      head :no_content
    else
      render json: @coupon.errors, status: :unprocessable_entity
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.json
  def destroy
    @coupon.destroy

    head :no_content
  end

  private

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(:coupon_template_id, :receiver_shop_id, :receiv_time, :receive_taget_id, :receive_taget_type, :customer_id, :start_time, :end_time, :status)
    end
end
