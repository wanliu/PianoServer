class RoomsController < ApplicationController
  include ConcernParentResource

  set_parent_param :promotion_id, class_name: 'Promotion'
  before_action :room_variables, only: [:owner, :target, :channel]
  before_action :get_order, only: [:owner, :target, :channel]

	def show
		@room = Room.find(params[:id])
		@order = Order.find(@room.order_id) if @room.order_id
		@target = my_room? ? @room.target : @room.owner
	end

	def owner
		@room = Room
			.both(params[:owner_id], current_anonymous_or_user.id)
			.first_or_create({
				owner_id: params[:owner_id],
				target_id: current_anonymous_or_user.id
			})

		unless @room.order_id
	    @room.order_id = @order.id
	    @room.save
	  end
		render :show
	end

	def target
		render :show
	end

	def channel
		render :show
	end

	def room_variables
		if @parent.is_a? Promotion
			@target = Shop.find(@parent.shop_id)
		end

		if @promotion.nil? and params[:promotion_id]
			@promotion = Promotion.find(params[:promotion_id])
		end
	end

	def get_order
		if @promotion
			@shop = Shop.find(@promotion.shop_id)
	    bid = Order.last_bid(current_anonymous_or_user.id) + 1
	    @order = Order
	    	.available(@shop.id, current_anonymous_or_user.id)
	      .first_or_create({
	        title: @promotion.title,
	        supplier_id: @shop.id,
	        buyer_id: current_anonymous_or_user.id,
	        bid: bid
	      })

	    @order.items.add_promotion(@promotion)
	  end
	end

	private

	def my_room?
		@room.owner_id == current_anonymous_or_user.id
	end

end
