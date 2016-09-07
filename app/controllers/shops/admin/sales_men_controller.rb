class Shops::Admin::SalesMenController < Shops::Admin::BaseController
  before_action :set_sales_man, only: [:show, :update, :destroy]

  # GET /sales_men
  # GET /sales_men.json
  def index
    @sales_men = current_shop.sales_men.includes(:user)
  end

  # GET /sales_men/1
  # GET /sales_men/1.json
  def show
    # render json: @sales_man
  end

  # POST /sales_men
  # POST /sales_men.json
  def create
    @sales_man = current_shop.sales_men.build(sales_man_params)

    respond_to do |format|
      if @sales_man.save
        format.js
        format.json { render json: @sales_man, status: :created }
      else
        format.js
        format.json { render json: @sales_man.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales_men/1
  # PATCH/PUT /sales_men/1.json
  def update
    respond_to do |format|
      if @sales_man.update(sales_man_update_params)
        format.json { head :no_content }
        format.js
      else
        format.json { render json: @sales_man.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /sales_men/1
  # DELETE /sales_men/1.json
  def destroy
    @sales_man.destroy

    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  def search
    # except_ids = current_shop.sales_man_ids.concat([current_shop.owner_id])
    except_ids = current_shop.sales_men.pluck(:user_id).concat([current_shop.owner_id])
    users = User.where("id NOT IN (:except_ids) AND (username LIKE :query OR nickname LIKE :query)", query: "%#{params[:q]}%", except_ids: except_ids).limit(10)
    render json: users.to_json(only: [:id], methods: [:avatar_url, :nickname])
  end

  # def add_weixin_user
    
  # end

  private

    def set_sales_man
      @sales_man = current_shop.sales_men.find(params[:id])
    end

    def sales_man_params
      params.require(:sales_man).permit(:user_id)
    end

    def sales_man_update_params
      params.require(:sales_man).permit(:phone)
    end
end
