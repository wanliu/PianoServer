class ShopsController < ApplicationController
  before_action :set_shop, only: [ :show_by_name, :show, :about ]
  before_action :set_theme
  before_action :prepare_shop_views_path
  before_action :shop_page_info, except: [ :update_name ]
  # caches_page :show, :show_by_name, :about

  def show_by_name
    set_page_title @shop.title

    unless ShopService.valid?(@shop)
      ShopService.build(params[:shop_name])
    end

    @root = @shop.shop_category(true)
    @shop_categories = @root.children.where(status: true)
    @theme_path = @shop.theme.blank? ? "shops" : "themes/#{@shop.theme}"

    render "show", with: @theme
  end

  def show
    # @shop = Shop.find params[:id]
    @shop_categories = @shop.shop_category.children.where(status: true).page(params[:page]).per(params[:per])
  end

  def create
  end

  def update_name
    @shop = Shop.new shop_params
    @shop.valid?
    render json: @shop
  end

  def about
    render :about
  end

  private

  def prepare_shop_views_path
    prepend_view_path ShopService.root
  end

  def set_shop
    @shop = Shop.find_by name: params[:shop_name] || params[:id]
    @shop.punch(request)
  end

  def set_theme
    @theme = Theme.new(@shop) if @shop.present?
  end

  def shop_page_info
    self.page_title += [ t("titles.shops", shop_name: @shop.title) ]
    self.page_navbar = @shop.title || @shop.name
    self.page_navbar_link = shop_site_path(@shop.name, format: 'html')
  end

  def shop_params
    params.require(:shop).permit(:name, :title)
  end
end
