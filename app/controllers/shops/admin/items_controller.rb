class Shops::Admin::ItemsController < Shops::Admin::BaseController
  include Shops::Admin::ItemHelper
  include ActionView::Helpers::SanitizeHelper

  before_action :set_category, only: [:new_step2, :create]
  before_action :set_breadcrumb, only: [:new_step2, :create]

  def load_categories
    page = params[:page].presence || 1
    per = params[:per].presence || 25

    @items = Item.with_shop(@shop.id)
                 .with_category(query_params[:category_id])
                 .with_query(query_params[:q])
                 .page(query_params[:page])

    @categories = if params[:category_id].present?
      ShopCategory.where(parent_id: params[:category_id])
    else
      shop_category_root.children
    end

    render json: {categories: @categories.as_json(methods: [:is_leaf]), items: @items }
  end

  def index
    # @items = Item.with_shop(@shop.id)
    #              .with_category(query_params[:category_id])
    #              .with_query(query_params[:q])
    #              .page(query_params[:page])

    # @categories = shop_category_root.children
  end

  def new
    redirect_to new_step1_shopitems_path(@shop.name)
  end

  def new_step1
    @item = Item.new(shop_id: @shop.id)
  end

  def commit_step1
    raise_404 if params[:category_id].to_i == 0

    redirect_to new_step2_shopitems_path(@shop.name, category_id: params[:category_id])
  end

  def new_step2
    @title = "创建自己的商品"
    @item = Item.new(category_id: @category.id, shop_id: @shop.id)
    @properties = @category.with_upper_properties
  end

  def create
    @title = "创建自己的商品"
    @properties = @category.with_upper_properties
    prop_params = properties_params(@properties)
    @item = Item.new item_basic_params.merge(shop_id: @shop.id) do |item|
      item.properties ||= {}

      @properties.each do |prop|
        config = item.properties[prop.name] = {
          title: prop.title,
          type: prop.prop_type,
          unit_id: prop.unit_id,
          unit_type: prop.unit_type
        }

        if prop.prop_type == "map"
          config["map"] = prop.data["map"]
        end
        config["value"] = prop_params["property_#{prop.name}"]
      end

      item.save
    end

    pp item_basic_params
    @item = Item.new(category_id: @category.id, shop_id: @shop.id) if @item.valid?
    # pp @item.errors.full_messages
    flash[:notice] = t("notices.controllers.items.create")
    render :new_step2
  end

  protected

  def query_params
    params.permit(:shop_id, :category_id, :q, :page)
  end

  def shop_category_root
    @category_root ||= @shop.shop_category
  end

  def raise_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def html_safe_params
    params[:description] = sanitize params[:description], tags: %w(script), attributes: %w(href)
    params
  end

  def item_basic_params
    _params = html_safe_params.require(:item).permit(:name, :title, :brand_id, :images, :price, :public_price,
      :income_price, :shop_category_id, :category_id, :description)
    _params[:description] = sanitize _params[:description], tags: %w(script), attributes: %w(href)
    _params
  end


  def properties_params(properties)
    params.require(:item).slice(*properties.map{ |prop| "property_#{prop.name}" })
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_breadcrumb
    @breadcrumb = @category.ancestors
  end
end
