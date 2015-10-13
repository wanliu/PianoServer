require 'combination_hash'

class Shops::Admin::ItemsController < Shops::Admin::BaseController
  include Shops::Admin::ItemHelper
  include ActionView::Helpers::SanitizeHelper
  include CombinationHash

  respond_to :json, :html

  before_action :set_category, only: [:new_step2, :create]
  before_action :set_breadcrumb, only: [:new_step2, :create]
  before_action :set_item, only: [:edit, :update, :destroy, :change_sale_state]

  def index
    # page = params[:page].presence || 1
    # per = params[:per].presence || 25

    @items = Item.with_shop(@shop.id)
                 .with_category(query_params[:category_id])
                 .with_query(query_params[:q])
                 .page(query_params[:page])

    @categories = if params[:category_id].present?
      ShopCategory.where(parent_id: params[:category_id])
    else
      shop_category_root.children
    end

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
    @properties = normal_properties(@category.with_upper_properties)
    @inventory_properties = inventory_properties(@category.with_upper_properties)
  end

  def create
    @title = "创建自己的商品"
    @properties = normal_properties(@category.with_upper_properties)
    @inventory_properties = inventory_properties(@category.with_upper_properties)
    prop_params = properties_params(@properties)
    @item = Item.new item_basic_params.merge(shop_id: @shop.id) do |item|
      item.properties ||= {}

      prop_params.each do |prop_name, value|
        item.send("#{prop_name}=", value)
      end

      item.send(:write_attribute, :images, params[:item][:filenames].split(','))
    end

    if @item.save
      if params[:submit] == "create_and_continue"
        @item = Item.new(category_id: @category.id, shop_id: @shop.id)
        flash.now[:notice] = t(:create, scope: "flash.notice.controllers.items.create")
        render :new_step2
      else
        redirect_to shop_admin_items_path(@shop.name), notice: t(:create, scope: "flash.notice.controllers.items.create")
      end
    else
      flash.now[:error] = t(:create, scope: "flash.error.controllers.items")
      render :new_step2
    end
  end

  def update
    @category = @item.category
    @breadcrumb = @category.ancestors
    @properties = normal_properties(@category.with_upper_properties)
    @inventory_properties = inventory_properties(@category.with_upper_properties)

    if params[:item][:filenames].present?
      @item.send(:write_attribute, :images, params[:item][:filenames].split(','))
    end

    item_basic_params.each do |k , v|
      @item.send("#{k}=", v)
    end

    prop_params = properties_params(@properties + @inventory_properties)

    @item.properties ||= {}

    prop_params.each do |prop_name, value|
      @item.send("#{prop_name}=", value)
    end

    if @item.save
      redirect_to shop_admin_items_path(@shop.name), notice: t(:update, scope: "flash.notice.controllers.items")
    else
      flash.now[:error] = t(:update, scope: "flash.error.controllers.items")
      render :edit
    end
  end

  def edit
    @category = @item.category
    @breadcrumb = @category.ancestors
    @properties = normal_properties(@category.with_upper_properties)
    @inventory_properties = inventory_properties(@category.with_upper_properties)
    @inventory_combination = combination_properties(@item, @inventory_properties)
  end

  def upload_image
    uploader = ItemImageUploader.new(Item.new, :images)
    uploader.store! params[:file]

    render json: { success: true, url: uploader.url(:cover)  , filename: uploader.filename }
  end

  def change_sale_state
    if @item.update_attributes(item_state_param)
      render json: { success: true }
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  protected

  def query_params
    params.permit(:shop_id, :category_id, :q, :page, :per)
  end

  def shop_category_root
    @category_root ||= @shop.shop_category
  end

  def raise_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def item_state_param
    params.require(:item).permit(:on_sale)
  end

  def item_basic_params
    _params = params.require(:item).permit(:name, :title, :brand_id, :images, :price, :public_price,
      :income_price, :shop_category_id, :category_id, :description)
    _params[:description] = sanitize _params[:description], tags: %w(script), attributes: %w(href)
    _params
  end

  def properties_params(properties)
    params.require(:item).slice(*properties.map{ |prop| "property_#{prop.name}" })
  end

  def normal_properties(properties)
    properties.reject { |prop| prop.data.try(:[], "group") }
  end

  def inventory_properties(properties)
    properties.select { |prop| prop.data.try(:[], "group") }
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_breadcrumb
    @breadcrumb = @category.ancestors
  end

  def set_item
    @item = Item.find(params[:id])
  end

  private

  def combination_properties(item, properties)
    props = format_hash(item, properties)
    hash = combination_hash(*props) do |*args|
      Hash[*args]
    end
 end

  def format_hash(item, properties)
    props = properties.map do |_prop|
      prop = item.send("property_#{_prop.name}") || {}
      hash = {}
      values = prop.select do |key, value|
        checked = (value || {})["check"]
        checked == "1" or checked == 1 or checked == true
      end.each do |key, value|
        hash[key] = (value || {})["title"]
      end
      Hash[_prop.title, hash]
    end
  end
end
