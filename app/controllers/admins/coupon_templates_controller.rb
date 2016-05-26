require "./lib/coupon_time_duration"

class Admins::CouponTemplatesController < Admins::BaseController
  before_action :set_coupon_template, only: [:show, :edit, :issue_form, :issue]

  # GET /coupon_templates
  # GET /coupon_templates.json
  def index
    @coupon_templates = CouponTemplate.system_templates
      .page(params[:page])
      .per(params[:per])

    # render json: @coupon_templates
  end

  def new
    initial_options = {
      overlap: false, 
      apply_time: 'fixed', 
      apply_minimal_total: 0, 
      apply_shops: 'all_shops',
      apply_items: 'all_items'
    }

    @coupon_template = CouponTemplate.new(initial_options)

    now = Time.now.beginning_of_hour
    @coupon_template.build_coupon_template_time(from: now, to: now + 1.month )

    @coupon_template.coupon_template_shops.build
  end

  # GET /coupon_templates/1
  # GET /coupon_templates/1.json
  def show
    # render json: @coupon_template
  end


  # POST /coupon_templates
  # POST /coupon_templates.json
  def create
    @coupon_template = CouponTemplate.system_templates.new(coupon_template_params)
    respond_to do |format|
      if @coupon_template.save
        format.html { redirect_to issue_admins_coupon_template_path(@coupon_template) }
        format.json { render json: @coupon_template, status: :created }
      else
        format.html { render "edit" }
        format.json { render json: @coupon_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def issue_form
  end

  def issue
    @coupon_template.assign_attributes(issue_params)

    respond_to do |format|
      if @coupon_template.create_coupons
        format.json { render json: {} }
        format.html do
          flash.notice = "发行成功！"
          redirect_to [:admins, @coupon_template]
        end
      else
        format.json { render json: { error: @coupon_template.errors }, status: :unprocessable_entity }
        format.html do
          flash.alert = @coupon_template.errors.full_messages.join(', ')
          # redirect_to [:issue, :admins, @coupon_template]
          render "issue_form"
        end
      end
    end
  end

  # PATCH/PUT /coupon_templates/1
  # PATCH/PUT /coupon_templates/1.json
  # def update
  #   @coupon_template = CouponTemplate.find(params[:id])

  #   if @coupon_template.update(coupon_template_params)
  #     head :no_content
  #   else
  #     render json: @coupon_template.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /coupon_templates/1
  # DELETE /coupon_templates/1.json
  # def destroy
  #   @coupon_template.destroy

  #   head :no_content
  # end

  private

    def set_coupon_template
      @coupon_template = CouponTemplate.system_templates.find(params[:id])
    end

    def coupon_template_params
      params.require(:coupon_template)
        .permit(
          :issuer_id, 
          :issuer_type, 
          :name, 
          :par, 
          :apply_items, 
          :apply_minimal_total, 
          :apply_shops, 
          :apply_time, 
          :overlap, 
          :desc,
          coupon_template_shops_attributes: [:shop_id],
          coupon_template_time_attributes: CouponTemplateTime.permit_attributes
        )
    end

    def issue_params
      params.require(:coupon_template).permit(:issue_quantity)
    end
end
