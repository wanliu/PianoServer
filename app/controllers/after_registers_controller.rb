class AfterRegistersController < ApplicationController
  before_action :set_type, only: [:show, :update]
  before_action :authenticate_user!

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
      @step = "product"

      categories = select_params.map {|id, brands| id }
      @categories = Category.where(id: categories).order(:id)
      @all_categories = @categories.map {|cate| {id: cate.id, categories: cate.self_and_descendants} }

      top_category_title = proc { |top, category_id| top[:categories].find {|c| c.id == category_id }.try(:title) }

      @products_group =
        @all_categories.map do |top|
          group = {}
          group[:type] = 'top'
          group[:id] = top[:id].to_s
          # top[:categories].first.tap { |c| group[:title] = c.title || c.name }
          group[:title] = top[:categories].first.title
          group[:total] = 0

          ids = top[:categories].map &:id


          results = Product.with_category_brands(ids, select_params[group[:id]])
          aggregations = results.response.aggregations

          group[:categories] =
            (aggregations.try(:all_category).try(:buckets) || []).map do |category_bucket|
              category = {}

              category[:type] = 'category'
              category[:id] = category_bucket["key"]
              category[:doc_count] = category_bucket["doc_count"]
              category[:title] = top_category_title.call top, category[:id]
              category[:total] = 0
              # group[:total] += category[:doc_count]

              category[:brands] =
                (category_bucket.try(:all_brands).try(:buckets) || []).map do |brand_bucket|
                  brand = {}
                  _brand = Brand.where(id: brand_bucket["key"]).first
                  brand[:type] = 'brand'
                  brand[:id] = brand_bucket["key"]
                  brand[:doc_count] = brand_bucket["doc_count"]
                  brand[:title] = _brand.try :title
                  brand[:icon_url] = _brand.try(:image).try(:url)
                  brand[:total] = brand_bucket.all_products.hits.hits.count
                  # brand[:total] += 1 if brand[:total] > Settings.after_registers.total.max_count || 10
                  category[:total] += brand[:total]

                  brand[:products] =
                    brand_bucket.try(:all_products).try(:hits).hits.map do |hit|
                      hit["_source"]
                    end
                  brand
                end
              group[:total] += category[:total]
              category
            end
          group
        end
      [:show, "product"]
    when "product"
      [true, "final"]
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

  def select_params
    params[:select]
  end
end
