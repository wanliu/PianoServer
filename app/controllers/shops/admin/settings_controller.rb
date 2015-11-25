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
    #接受ajax请求 生成指定风格商店
    begin
      ShopService.build(params[:shop_id], { theme: params[:theme] })
      render json: { success: true }
    rescue Exception => e
      render json: { success: false, msg: e.message }
    end
  end

  private

  def setting_params
    params.require(:setting)
  end
end
