class Shops::Admin::DeliversController < Shops::Admin::BaseController
  include DeliveryAreaTitle

  def index
    @delivers = current_shop.shop_delivers.includes(:deliver)
  end

  def show
  end

  def create
    @deliver = current_shop.shop_delivers.build(user_id: params[:deliver][:user_id])
    respond_to do |format|
      if @deliver.save
      else
      end
    end
  end

  def destroy
    @deliver = current_shop.shop_delivers.find(params[:id])
    @deliver.destroy

    respond_to do |format|
      format.json { head :no_content }
      format.html { head :no_content }
      format.js
    end
  end
end