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
    exsited_item = current_cart.items.where("
      cartable_id = :cartable_id AND cartable_type = :cartable_type AND properties @> :properties",
      cartable_id: params[:cart_item][:cartable_id],
      cartable_type:  params[:cart_item][:cartable_type],
      properties: (params[:cart_item][:properties] || {}).to_json).first

    if exsited_item.present?
      @item = exsited_item
      @item.quantity += params[:cart_item][:quantity].to_i
      @item.price = exsited_item.caculate_price
    else
      @item = current_cart.items.new(cart_item_params) do |item|
        item.price = item.caculate_price
        item.supplier_id = item.cartable.try(:shop_id)
      end
    end

    if @item.save
      render :create, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def update
    unless @item.update(update_params)
      render json: @item.errors, status: :unprocessable_entity
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
      .permit(:supplier_id, :title, :sale_mode, :quantity,
        :condition, :cartable_id, :cartable_type).tap do |white_list|
        white_list[:properties] = params[:cart_item][:properties] || {}
      end
  end

  def update_params
    params.require(:cart_item).permit(:quantity)
  end

  def cart_item_update_params
    params.require(:cart_item).permit(:quantity, :properties, :condition)
  end
end