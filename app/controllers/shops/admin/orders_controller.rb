class Shops::Admin::OrdersController < Shops::Admin::BaseController
  before_action :set_order, only: [:show, :update, :destroy]

  # GET /shops/admin/orders
  # GET /shops/admin/orders.json
  def index
    # @orders = current_shop.orders.order(id: :desc).page(params[:page]).per(params[:per])
    @orders = current_shop
      .orders
      .initiated
      .includes(:items, :buyer)
      .order(id: :desc)
      .page(params[:page])
      .per(params[:per])
  end

  def history
    @orders = current_shop
      .orders
      .finish
      .includes(:items, :buyer)
      .order(id: :desc)
      .page(params[:page])
      .per(params[:per])
  end

  # GET /shops/admin/orders/1
  # GET /shops/admin/orders/1.json
  def show
  end

  # POST /shops/admin/orders
  # POST /shops/admin/orders.json
  # def create
  #   @order = Order.new(order_params)

  #   if @order.save
  #     render json: @order, status: :created, location: @order
  #   else
  #     render json: @order.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /shops/admin/orders/1
  # PATCH/PUT /shops/admin/orders/1.json
  def update
    respond_to do |format|
      if @order.update(total: order_params[:total])
        format.html { redirect_to shop_admin_order_path(current_shop.name, @order), notice: '订单修改成功' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { redirect_to shop_admin_order_path(current_shop.name, @order), 
          alert: "订单修改失败, #{@order.errors.full_messages.join(', ')}" }

        format.json { render json: @bank.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shops/admin/orders/1
  # DELETE /shops/admin/orders/1.json
  def destroy
    if @order.destroy
      head :no_content
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

    def set_order
      @order = current_shop.orders.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:total)
    end
end
