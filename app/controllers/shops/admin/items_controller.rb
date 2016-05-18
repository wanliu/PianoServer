require 'combination_hash'

class Shops::Admin::ItemsController < Shops::Admin::BaseController
  include Shops::Admin::ItemHelper
  include ActionView::Helpers::SanitizeHelper
  include CombinationHash
  include DeliveryAreaTitle

  respond_to :json, :html

  before_action :set_category, only: [:new_step2, :create]
  before_action :set_breadcrumb, only: [:new_step2, :create]
  before_action :set_item, only: [:edit, :update, :destroy, :change_sale_state]

  def index
    # page = params[:page].presence || 1
    # per = params[:per].presence || 25

    @items = Item.with_shop(@shop.id)
                 # .where(abandom: false)
                 .with_category(query_params[:category_id])
                 .with_query(query_params[:q])
                 .page(query_params[:page])
                 .order(id: :desc)

    @categories = if params[:category_id].present?
      ShopCategory.where(parent_id: params[:category_id])
    else
      shop_category_root.children
    end

    @brands = Brand.joins(:items).where("items.id in (?)", @items.map {|item| item.id }).group "brands.id"

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
    @category_groups = @shop.shop_category.leaves
      .group_by {|category| category.parent }
      .map {|group, items| [ group.self_and_ancestors.map{ |parent| parent.title }.join(' » '), items.map {|i| [i.title, i.id]}]}

    @inventory_properties = inventory_properties(@category.with_upper_properties)

    if Settings.dev.feature.inventory_combination and @inventory_properties.present?
      @inventory_combination = combination_properties(@item, @inventory_properties)
      @stocks_with_index = {}
    end
  end

  def create
    @title = "创建自己的商品"
    properties_setting = @category.with_upper_properties
    @properties = normal_properties(properties_setting)
    @inventory_properties = inventory_properties(properties_setting)
    @category_groups = @shop.shop_category.leaves
      .group_by {|category| category.parent }
      .map {|group, items| [ group.self_and_ancestors.map{ |parent| parent.title }.join(' » '), items.map {|i| [i.title, i.id]}]}

    prop_params = properties_params(@properties + @inventory_properties)

    @item = Item.new item_basic_params.merge(shop_id: @shop.id) do |item|
      item.properties ||= {}

      item.sid = Item.last_sid(@shop) + 1

      prop_params.each do |prop_name, value|
        property = @inventory_properties.find {|item| prop_name == "property_#{item.name}" }

        title = property.try(:title)
        exterior = property.try(:exterior)
        prop_type = property.try(:prop_type)
        item.send("#{prop_name}=", value, title: title, exterior: exterior, prop_type: prop_type)
      end

      item.properties_setting = properties_setting

      if params[:item][:filenames] && params[:item][:filenames].respond_to?(:split)
        item.send(:write_attribute, :images, params[:item][:filenames].split(','))
      end
    end

    if Settings.dev.feature.inventory_combination and @inventory_properties.present?
      @inventory_combination = combination_properties(@item, @inventory_properties)
    end

    if Rails.env.development?
      pp params["inventories"]
    end

    stock_options = params["inventories"] || params["inventory"]
    @item.build_stocks(current_user, stock_options)

    if @item.save
      expire_page controller: 'items', action: 'show', id: @item.sid
      expire_page shop_shop_category_path(@shop.name, @item.shop_category.try(:id))

      if params[:commit] == "新增并继续"
        @item = Item.new(category_id: @category.id, shop_id: @shop.id)
        flash.now[:notice] = t(:create, scope: "flash.notice.controllers.items")
        @stocks_with_index = {}
        render :new_step2
      else
        redirect_to shop_admin_items_path(@shop.name), notice: t(:create, scope: "flash.notice.controllers.items")
      end
    else
      flash.now[:error] = t(:create, scope: "flash.error.controllers.items")
      set_stocks_for_feedback

      render :new_step2, status: :unprocessable_entity
    end
  end

  def update
    @category = @item.category
    @breadcrumb = @category.ancestors

    properties_setting = @item.properties_setting
    @properties = normal_properties(properties_setting)
    @inventory_properties = inventory_properties(properties_setting)

    @category_groups = @shop.shop_category.leaves
      .group_by {|category| category.parent }
      .map {|group, items| [ group.self_and_ancestors.map{ |parent| parent.title }.join(' » '), items.map {|i| [i.title, i.id]}]}

    if Settings.dev.feature.inventory_combination and @inventory_properties.present?
      @inventory_combination = combination_properties(@item, @inventory_properties)
    end

    if Rails.env.development?
      pp params["inventories"]
    end

    if params[:item][:filenames] && params[:item][:filenames].respond_to?(:split)
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

    stock_options = params["inventories"] || params["inventory"]

    if stock_options.present?
      @item.adjust_stocks(current_user, stock_options)
    else
      flash.now[:error] = "库存设置错误，请正确填写"
      set_stocks_for_feedback
      set_express_fee

      render :edit
      return
    end

    if @item.save
      expire_page shop_item_path(@shop.name, @item.sid)
      # expire_page controller: 'items', action: 'show', id: @item.sid
      expire_page shop_shop_category_path(@shop.name, @item.shop_category.try(:id))
      # expire_page controller: 'shop_categories', action: 'show', id: @item.shop_category.try(:id)

      redirect_to shop_admin_items_path(@shop.name), notice: t(:update, scope: "flash.notice.controllers.items")
    else
      flash.now[:error] = t(:update, scope: "flash.error.controllers.items")
      set_stocks_for_feedback
      set_express_fee

      render :edit, status: :unprocessable_entity
    end
  end

  def edit
    @category = @item.category
    @breadcrumb = @category.ancestors

    properties_setting = @item.properties_setting
    @properties = normal_properties(properties_setting)
    @inventory_properties = inventory_properties(properties_setting)

    @category_groups = @shop.shop_category.leaves
      .group_by {|category| category.parent }
      .map {|group, items| [ group.self_and_ancestors.map{ |parent| parent.title }.join(' » '), items.map {|i| [i.title, i.id]}]}

    if Settings.dev.feature.inventory_combination and @inventory_properties.present?
      @inventory_combination = combination_properties(@item, @inventory_properties)
      @stocks_with_index = @item.stocks_with_index
    end

    @stock = @item.stock_changes.sum(:quantity)

    set_express_fee
  end

  def inventory_config
    @item = Item.new(item_basic_params)
    @category = @item.category
    @inventory_properties = inventory_properties(@category.with_upper_properties)
    @item.properties ||= {}

    prop_params = properties_params(@inventory_properties)

    prop_params.each do |prop_name, value|
      @item.send("#{prop_name}=", value)
    end

    if Settings.dev.feature.inventory_combination and @inventory_properties.present?
      @inventory_combination = combination_properties(@item, @inventory_properties)

      set_stocks_for_feedback
    end

    render partial: "inventory_form", layout: false
  end

  def upload_image
    uploader = ItemImageUploader.new(Item.new, :images)
    uploader.store! params[:file]

    render json: { success: true, url: uploader.url(:cover)  , filename: uploader.filename }
  end

  def change_sale_state
    if @item.update_attribute("on_sale", params[:item][:on_sale])
      expire_page shop_shop_category_path(@shop.name, @item.shop_category.try(:id))
      render json: { success: true }
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @item.update_attribute('abandom', true)

    expire_page shop_shop_category_path(@shop.name, @item.shop_category.try(:id))

    render :destroy, formats: [:js]
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

  def item_basic_params
    params.require(:item).permit(:name, :title, :brand_id, :images, :price, :public_price,
      :income_price, :shop_category_id, :category_id, :description)
  end

  def properties_params(properties)
    params.require(:item).slice(*properties.map{ |prop| "property_#{prop.name}" })
  end

  def normal_properties(properties)
    properties.reject { |prop| prop.prop_type == "stock_map" }
  end

  def inventory_properties(properties)
    properties.select { |prop| prop.prop_type == "stock_map" }
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_breadcrumb
    @breadcrumb = @category.ancestors
  end

  def set_item
    @item = @shop.items.find_by_key(params)
  end

  private

  def combination_properties(item, properties)
    props = format_hash(item, properties)
    hash = combination_hash(*props) do |*args|
      Hash[*args]
    end
    hash
  end

  def format_hash(item, properties)
    props = properties.map do |_prop|
      item_config(item, _prop) do |prop, hash|
        Hash[prop, hash]
      end
    end
  end

  def item_config(item, prop)
    config = item.send("property_#{prop.name}")
    hash = {}

    if !config.blank?
      config.select do |key, value|
        checked = (value || {})["check"]
        checked == "1" or checked == 1 or checked == true
      end.each do |key, value|
        hash[key] = (value || {})["title"]
      end
    else
      hash = prop.data["map"]
    end

    yield prop, hash if block_given?
  end

  def set_stocks_for_feedback
    if params[:inventories].present?
      @stocks_with_index = StockChange.extract_stocks_with_index(params[:inventories])
    end
  end

  def set_express_fee
    @delivery_fee_settings = @item.delivery_fee || {}
    @delivery_fee_settings.each do |code, fee|
      @delivery_fee_settings[code] = {
        fee: fee,
        title: get_code_title(code)
      }
    end
  end
end
