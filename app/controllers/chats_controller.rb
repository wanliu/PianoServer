class ChatsController < ApplicationController
  include ConcernParentResource

  set_parent_param :promotion_id, class_name: 'Promotion'
  before_action :chat_variables, only: [:owner, :target, :channel]
  before_action :get_order, only: [:owner, :target, :channel]

  def index
    @chats = Chat.in(current_anonymous_or_user.id)
    # @chats = current_anonymous_or_user.chats
  end

	def show
		@chat = Chat.find(params[:id])
		@order = Order.find(@chat.order_id) if @chat.order_id
		@target = my_chat? ? @chat.target : @chat.owner
	end

	def owner
		@chat = Chat
			.both(params[:owner_id], current_anonymous_or_user.id)
			.first_or_create({
				owner_id: params[:owner_id],
				target_id: current_anonymous_or_user.id
			})

		unless @chat.order_id
	    @chat.order_id = @order.id
	    @chat.save
	  end
		render :show
	end

	def target
		render :show
	end

	def channel
		render :show
	end

	def chat_variables
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

	def my_chat?
		@chat.owner_id == current_anonymous_or_user.id
	end

end
