class Shops::Admin::SettingsController < Shops::Admin::BaseController
  def index
    @settings = OpenStruct.new @shop.settings
    @theme_list = [
      {type:'theme1', name:'冰封雪域'},
      {type:'theme2', name:'夏日阳光'},
      {type:'theme3', name:'蔚蓝天空'},
      {type:'theme4', name:'星际探险'},
      {type:'theme5', name:'咖啡时光'}
    ]
  end

  def create
    key   = setting_params.keys[0]
    value = setting_params[key]
    @shop.update_attribute(key, value)
    render nothing: true
  end

  def reset_shop_poster
    @shop.update_attribute('poster', nil)

    render json: { success: true, msg:'重置海报成功' }
  end

  def upload_shop_poster
    uploader = ImageUploader.new(@shop, :poster)
    uploader.store! params[:file]

    if @shop.update_attribute('poster', uploader.url)
      expire_page shop_site_path(@shop.name)

      render json: { success: true, url: uploader.url, filename: uploader.filename }
    else
      render json: { success: false }
    end
  end

  def upload_shop_signage
    uploader = ImageUploader.new(@shop, :head_url)
    uploader.store! params[:file]

    if @shop.update_attribute('head_url', uploader.url)
      expire_page shop_site_path(@shop.name)

      render json: { success: true, url: uploader.url, filename: uploader.filename }
    else
      render json: { success: false }
    end
  end

  def change_shop_theme
    begin
      shop = Shop.find_by(name: params[:shop_id])
      theme = params[:theme]
      dir = File.join(Rails.root, Settings.sites.shops.root, shop.name, "theme_#{ theme }")

      unless File.exists? dir
        ShopService.build(params[:shop_id], { theme: theme })
      end

      shop.update_attribute('theme', theme)

      expire_page shop_site_path(@shop.name)

      render json: { success: true, msg: 'success' }
    rescue Exception => e
      render json: { success: false, msg: e.message }
    end
  end

  private

  def setting_params
    params.require(:setting)
  end
end
