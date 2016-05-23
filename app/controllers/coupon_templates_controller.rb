class CouponTemplatesController < ApplicationController
  before_action :set_coupon_template, only: [:show, :update, :destroy]

  # GET /coupon_templates
  # GET /coupon_templates.json
  def index
    @coupon_templates = CouponTemplate.all

    render json: @coupon_templates
  end

  # GET /coupon_templates/1
  # GET /coupon_templates/1.json
  def show
    render json: @coupon_template
  end

  # POST /coupon_templates
  # POST /coupon_templates.json
  def create
    @coupon_template = CouponTemplate.new(coupon_template_params)

    if @coupon_template.save
      render json: @coupon_template, status: :created, location: @coupon_template
    else
      render json: @coupon_template.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /coupon_templates/1
  # PATCH/PUT /coupon_templates/1.json
  def update
    @coupon_template = CouponTemplate.find(params[:id])

    if @coupon_template.update(coupon_template_params)
      head :no_content
    else
      render json: @coupon_template.errors, status: :unprocessable_entity
    end
  end

  # DELETE /coupon_templates/1
  # DELETE /coupon_templates/1.json
  def destroy
    @coupon_template.destroy

    head :no_content
  end

  private

    def set_coupon_template
      @coupon_template = CouponTemplate.find(params[:id])
    end

    def coupon_template_params
      params.require(:coupon_template).permit(:issuer_id, :issuer_type, :name, :par, :appliy_items, :apply_minimal_total, :apply_shops, :apply_time, :overlap)
    end
end
