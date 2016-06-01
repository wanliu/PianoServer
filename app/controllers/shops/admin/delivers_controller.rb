class Shops::Admin::DeliversController < Shops::Admin::BaseController
  def index
    @delivers = current_shop.shop_delivers.includes(:deliver)
  end

  def show
  end

  def create
    @deliver = current_shop.shop_delivers.build(deliver_id: params[:deliver][:user_id])
    @deliver.save
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @deliver = current_shop.shop_delivers.find(params[:id])
    @deliver.destroy

    respond_to do |format|
      format.json { head :no_content }
      format.js
    end
  end

  def search_new_delivers
    except_ids = current_shop.deliver_ids.concat([current_shop.owner_id])
    users = User.where("id NOT IN (:except_ids) AND (username LIKE :query OR nickname LIKE :query)", query: "%#{params[:q]}%", except_ids: except_ids).limit(10)
    render json: users.to_json(only: [:id], methods: [:avatar_url, :username])
  end
end