class AfterRegistersController < ApplicationController
  before_action :set_type, only: [:show, :update, :status]
  before_action :authenticate_user!
  # before_action :expires_now, only: [:update]
  before_action :set_cache_headers, only: [:update]

  def index
    redirect_to after_register_path(current_user.user_type) unless current_user.user_type.nil?
  end

  def show
    case @current_user.user_type
    when nil, "distributor"
      distributor_steps
    when "consumer"
      consumer_steps
    when "retail"
      retail_steps
    end
  end

  def update
    status, step =
      case @current_user.user_type
      when NilClass, "distributor"
        go_distributor_steps
      when "consumer"
        consumer_steps
      when "retail"
        retail_steps
      end

    if status == :save or status == true
      @current_user.build_status state: step
      @current_user.save
      redirect_to after_register_path(@user_type)
    elsif status == :redirect
      redirect_to after_register_path(@user_type, step: step)
    elsif status == :show
      render :show, query: { step: step }
    elsif status == :error or status == false
      render :show
    else
      redirect_to after_register_path(@user_type)
    end

  end

  def distributor_steps
    case @current_user.state
    when "select", nil
    when "industry"
      @shop = @current_user.owner_shop || Shop.new(owner_id: @current_user.id)
    when "shop"
      @industry = @current_user.industry
    when "category"
      # @shop = @current_user.owner_shop || Shop.new(owner_id: @current_user.id)

      categories = Category.where(id: select_params.map {|id, brands| id }).to_a
      brands = select_params.map {|id, brands| brands }.flatten

      results = Product.with_category_brands(categories, brands)

      @product_group = results.response.aggregations
    when "product"

      # @brands = Brand.first(100)
    when NilClass
    else
    end
  end

  def go_distributor_steps
    case params[:step]
    when "select", NilClass
      @current_user.user_type = @user_type.to_sym
      [ true, "select" ]
    when "industry"
      [ true, "industry" ]
    when "shop"
      @shop = Shop.find_or_initialize_by shop_params
      ShopService.build @shop.name
      if @shop.save
        [true, "shop"]
      else
        [:error, "industry"]
      end
    when "category"

      go_category_step
    when "product"
      go_product_step
      # [true, "final"]
    when NilClass
    else
    end
  end


  def go_category_step
    @select_params = select_params
    @shop = @current_user.owner_shop

    @job = JobService.start(:generate_products_group, @shop, @select_params, type: "after_registers/category")
    @products_group = @job.output["products_group"]
    [:show, "product"]
  end

  def go_product_step
    @shop = @current_user.owner_shop

    @job = JobService.start(:batch_import_products, @shop, @shop, products_params, select_params, type: "after_registers/product")
    @created = @job.output["created"]
    [false, "shop"]
  end

  def status
    @step = params[:step]
    @shop = @current_user.owner_shop
    @job = Job.find_or_initialize_by jobable: @shop, job_type: "after_registers/#{@step}"
    render "after_registers/#{@user_type}/status", formats: [:json]
  end

  private

  def set_type
    @user_type = params[:id]
  end

  def shop_params
    params.require(:shop).permit(:title, :name, :phone, :description, :address, :owner_id)
  end

  def select_params
    params[:select]
  end

  def products_params
    params[:products]
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
