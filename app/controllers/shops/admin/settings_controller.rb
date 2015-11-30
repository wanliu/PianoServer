class Shops::Admin::SettingsController < Shops::Admin::BaseController

  def index
    @settings = OpenStruct.new @shop.settings
    @theme_list = [
      {type:'theme1', name:'冰封雪域'},
      {type:'theme2', name:'夏日阳光'},
      {type:'theme3', name:'蔚蓝天空'}
    ]
  end

  def create
    key   = setting_params.keys[0]
    value = setting_params[key]
    @shop.update_attribute(key, value)
    render nothing: true
  end

  def change_shop_theme
    begin
      shop = Shop.find_by(name: params[:shop_id])
      dir = File.join(Rails.root, Settings.sites.shops.root, shop.name, "theme_#{ params[:theme]}")

      unless File.exists? dir
        ShopService.build(params[:shop_id], { theme: params[:theme] })
      end
        
      shop.theme = params[:theme]
      shop.save!
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
