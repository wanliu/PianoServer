class CartsController < ApplicationController
  # before_action :set_cart
  class DisallowSaleMode < ActiveModel::ForbiddenAttributesError; end

  before_action :check_for_mobile, only: [:show]

  def show
    @items = current_cart.items.includes(:cartable)
  end

  # def add
  #   if allow_sale_modes.include? sale_mode

  #     @cart.items.build cartitem_params do |item|
  #       price =
  #         case item.cartable
  #         when Item
  #           if sale_mode == "retail"
  #             item.cartable.public_price
  #           else
  #             item.cartable.price
  #           end
  #         when Promotion
  #           unless sale_mode == "retail"
  #             item.cartable.price
  #           end
  #         when NilClass
  #           0
  #         else
  #           0
  #         end

  #         item.price = price
  #     end
  #     @cart.save
  #   else
  #     raise DisallowSaleMode.new("禁止的销售模式 #{sale_mode}")
  #   end

  #   render nothing: true
  # end

  # def remove
  #   @cartitem = @cart.items.find(params[:id])
  #   @cartitem.destroy if @cartitem
  #   render :remove
  # end

  def commit
  end

  private

  # def set_cart
  #   @cart = current_anonymous_or_user.cart
  # end

  # def allow_sale_modes
  #   if current_anonymous_or_user.user_type == "consumer"
  #     %w(retail)
  #   else
  #     %w(retail wholesale)
  #   end
  # end

  # def sale_mode
  #   params[:cart_item][:sale_mode]
  # end

  # def cartitem_params
  #   params.require(:cart_item).permit(:title, :quantity, :cartable_type, :cartable_id, :supplier_id, :image, :sale_mode)
  # end

end
