class CouponsController < ApplicationController
  before_action :set_coupon, only: [:show, :destroy]
  before_action :authenticate_user!

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
    # @coupon = Coupon.new(coupon_params)
    # @coupon_template = CouponTemplate.find(params[:coupon][:coupon_template_id])
    token = params[:token]
    @coupon_token = current_user.coupon_tokens.find_by(token: token)

    if @coupon_token.present?
      @coupon_template = @coupon_token.coupon_template

      if @coupon_template.present?
        @coupon = @coupon_template.allocate_coupon(current_user, @coupon_token)
        if @coupon.present?
          flash.notice = "恭喜你成功领到购物卷！"
          redirect_to coupon_path(@coupon)
        else
          flash.alert = "很遗憾！你迟到了一步，下次在来吧。"
          redirect_to draw_coupons_path(coupon_template_id: @coupon_template.id)
        end
      else
        flash.alert = "领取失败，再试一次吧！"
        redirect_to draw_coupons_path(coupon_template_id: @coupon_template.id)
      end
    else
      flash.alert = "领取失败，本页面已过期！"
      redirect_to expired_coupons_path
    end
  end

  # PATCH/PUT /coupons/1
  # PATCH/PUT /coupons/1.json
  # def update
  #   @coupon = Coupon.find(params[:id])

  #   if @coupon.update(coupon_params)
  #     head :no_content
  #   else
  #     render json: @coupon.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /coupons/1
  # DELETE /coupons/1.json
  def destroy
    @coupon.destroy

    head :no_content
  end

  def draw
    @coupon_template = CouponTemplate.find(params[:coupon_template_id])
    @drawed_counter = @coupon_template.drawed_coupons.count

    @coupon_token = CouponToken.find_or_generate(
      coupon_template_id: @coupon_template.id,
      customer_id: current_user.id
    )

    @coupon = @coupon_template.coupons.build
  end

  private

    def set_coupon
      @coupon = current_user.coupons.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(:coupon_template_id)
    end
end
