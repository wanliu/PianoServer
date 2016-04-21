class Shops::Admin::OrdersController < Shops::Admin::BaseController
  before_action :set_delivery_shop_and_order, only: :qrcode_receive
  before_action :set_order, only: [:show, :update, :destroy, :qrcode_receive]
  before_action :check_for_mobile, only: [:index, :history, :show, :qrcode_receive]

  skip_before_action :shop_page_info, only: :qrcode_receive
  skip_before_action :set_shop, only: :qrcode_receive

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
        format.html do
          redirect_to shop_admin_order_path(current_shop.name, @order), 
            flash: { error: "订单修改失败, #{@order.errors.full_messages.join(', ')}" }
        end

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

  def export_excel
    if params[:initiated].present?
      orders = current_shop.orders.initiated.includes(items: :orderable).order(id: :desc)
      spreadsheet = orders.to_spreadsheet("未完成订单")
    elsif params[:finish].present?
      orders = current_shop.orders.finish.includes(items: :orderable).page(params[:page])
        .per(params[:per]).order(id: :desc)
      spreadsheet = orders.to_spreadsheet("已完成订单(第#{params[:page]}页)")
    else
      orders = current_shop.orders.none
      spreadsheet = orders.to_spreadsheet
    end


    file_name = "#{current_shop.title}-#{Time.now.strftime('%Y%m%d%H%M%S')}#{Time.now.tv_usec}导出订单.xls"
    temp_sheet = StringIO.new
    spreadsheet.write temp_sheet
    send_data temp_sheet.string, :filename => file_name # :type => "application/vnd.ms-excel"
  end

  def qrcode_receive
    receive_token = params[:t]
    if @order.finish?
      flash[:alert] = '订单已经收货完成，无需再次收货'
      @receive = 'done already'
    else
      if Devise.secure_compare(@order.receive_token, receive_token)
        @order.finish!
        @receive = 'yes'
      else
        flash[:error] = '无效的收货编码，无法完成收货！'
        @receive = 'no'
      end
    end
  end

  private

    def set_delivery_shop_and_order
      @shop = Shop.name_and_deliverable_by(shop_name: params[:shop_id], user_id: current_user.id)
      raise ActiveRecord::RecordNotFound if @shop.blank?
      content_for :module, :shop_admin
    end

    def set_order
      @order = @shop.orders.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:total)
    end
end
