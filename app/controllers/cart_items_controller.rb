class CartItemsController < ApplicationController
  before_action :set_cart_item, only: [:show, :destroy, :update]

  def index
    @items = current_cart.items
    render json: @items
  end

  def show
    @item = current_cart.items.find(params[:id])
    render json: @item
  end

  def create
    exsited_item = current_cart.items.find_by(cartable_id: params[:cart_item][:cartable_id], cartable_type: params[:cart_item][:cartable_type])

    if exsited_item.present?
      @item = exsited_item
      @item.quantity += params[:cart_item][:quantity].to_i
    else
      sale_mode = current_anonymous_or_user.sale_mode

      @item = current_cart.items.new(cart_item_params) do |item|
        price =
          case item.cartable
          when Item
            if sale_mode == "retail"
              item.cartable.public_price
            else
              item.cartable.price
            end
          when Promotion
            item.cartable.discount_price
          else
            0
          end

        item.price = price
        item.supplier_id = item.cartable.try(:shop_id)
      end
    end

    if @item.save
      render :create, status: :created
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    unless @item.update(update_params)
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy

    respond_to do |format|
      format.html { redirect_to cart_path }
      format.json { render json: {}, status: :no_content }
    end
  end

  private

  def set_cart_item
    @item = current_cart.items.find(params[:id])
  end

  def cart_item_params
    # t.integer  "cartable_id"
    # t.string   "cartable_type"
    # t.integer  "supplier_id"
    # t.string   "title"
    # t.string   "image"
    # t.integer  "sale_mode",                              default: 0
    # t.decimal  "price",         precision: 10, scale: 2
    # t.integer  "quantity"
    # t.jsonb    "properties"
    # t.jsonb    "condition"
    params.require(:cart_item)
      .permit(:supplier_id, :title, :sale_mode, :quantity, :properties,
        :condition, :cartable_id, :cartable_type)
  end

  def update_params
    params.require(:cart_item).permit(:quantity)
  end

  def cart_item_update_params
    params.require(:cart_item).permit(:quantity, :properties, :condition)
  end
end