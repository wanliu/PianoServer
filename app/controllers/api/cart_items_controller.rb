class Api::CartItemsController < Api::BaseController
  include AnonymousController

  skip_before_action :authenticate_user!

  def index
    current_cart = current_anonymous_or_user.cart

    render json: {items_count: current_cart.items_count}
  end

  def create
    current_cart = current_anonymous_or_user.cart

    exsited_item = current_cart.items.where("
      cartable_id = :cartable_id AND cartable_type = :cartable_type AND properties @> :properties",
      cartable_id: params[:cart_item][:cartable_id],
      cartable_type:  params[:cart_item][:cartable_type],
      properties: (params[:cart_item][:properties] || {}).to_json).first

    if exsited_item.present?
      @item = exsited_item
      @item.quantity += params[:cart_item][:quantity].to_i
    else
      # sale_mode = current_anonymous_or_user.sale_mode

      @item = current_cart.items.new(cart_item_params) do |item|
        price =
          case item.cartable
          when Item
            # if sale_mode == "retail"
              # item.cartable.public_price
            # else
            item.cartable.price
            # end
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
      render json: @item, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  private

  def cart_item_params
    params.require(:cart_item)
      .permit(:supplier_id, :title, :sale_mode, :quantity,
        :condition, :cartable_id, :cartable_type).tap do |white_list|
        white_list[:properties] = params[:cart_item][:properties] || {}
      end
  end
end
