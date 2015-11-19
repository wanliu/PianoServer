class ChatsController < ApplicationController
  include ConcernParentResource

  set_parent_param :promotion_id, class_name: 'Promotion'
  before_action :chat_variables, only: [:owner, :target, :channel]
  before_action :get_intention, only: [:owner, :target, :channel, :shop_items]
  # before_action :set_page_info, only: [:show]

  def index
    @chats = Chat.in(current_anonymous_or_user.id).reverse_order
    @other_sides = @chats.map{ |chat| chat.other_side(current_anonymous_or_user) }
    # @chats = current_anonymous_or_user.chats
  end

  def create
    @chat = if params[:shop_id]
              create_chat_with_shop
            elsif params[:user_id]
              create_chat_with_user
            end

    @intention = if params[:promotion_id]
               create_intention_with_promotion
             elsif params[:item_id]
               create_intention_with_item
             end

    @chat.intention_id = @intention.id if @intention
    @chat.save

    redirect_to @chat
  end


  def create_chat_with_shop
    @shop = Shop.find(params[:shop_id])
    @chat = Chat.where(chatable_type: Shop.name, chatable_id: @shop.id, owner_id: current_anonymous_or_user.id).first_or_create target_id: @shop.owner_id
    @chat
  end

  def create_chat_with_user
    @user = User.find(params[:user_id])
    @chat = Chat.where(chatable_type: User.name, chatable_id: @user.id, owner_id: current_anonymous_or_user.id).first_or_create
  end

  def create_intention_with_promotion
    @promotion = Promotion.find(params[:promotion_id])
    @intention = Intention
      .where(supplier_id: @shop.id, buyer_id: current_anonymous_or_user.id)
      .first_or_initialize({})
    @intention.update_attributes({
      title: @promotion.title,
      bid: Intention.last_bid(current_anonymous_or_user.id) + 1
    })
    @intention.items.add_promotion(@promotion)
    @intention
  end

  def create_intention_with_item
    @item = Item.find(params[:item_id])
    @intention = Intention
      .where(supplier_id: @shop.id, buyer_id: current_anonymous_or_user.id)
      .first_or_initialize({})

    @intention.update_attributes({
      title: @item.title,
      bid: Intention.last_bid(current_anonymous_or_user.id) + 1
    })
    @intention.items.add_shop_product(@item)
    @intention
  end

	def show

		@chat = Chat.find(params[:id])
    if @chat.intention_id
		  @intention = Intention.find(@chat.intention_id)
      @buyer = @intention.buyer
      @supplier = @intention.supplier
    end
    #@target = @chat.chatable || @chat.target
    unless current_anonymous_or_user.id == @chat.owner.id or (@chat.target.is_a?(User) and current_anonymous_or_user.id == @chat.target.id)
      return redirect_to chats_path
    end

		@target = my_chat? ? @chat.target : @chat.owner
    @chats = Chat.in(current_anonymous_or_user.id)

    set_page_title "与 #{@target.name} 洽谈"
    set_page_navbar "#{@target.name}", @target.is_a?(Shop) ? shop_site_path(@target.name) : ''

    if @buyer && @buyer.id == current_anonymous_or_user.id and
      DateTime.now - 15.seconds < @chat.created_at && @supplier
      @greetings = @supplier.greetings
    end

    MessageSystemService.send_read_message current_anonymous_or_user.id, other_side if @intention
	end

	def chat_variables
		if @parent.is_a? Promotion
			@target = Shop.find(@parent.shop_id)
		end

		if @promotion.nil? and params[:promotion_id]
			@promotion = Promotion.find(params[:promotion_id])
		end
	end

	def get_intention
		if @promotion
			@shop = Shop.find(@promotion.shop_id)
	    bid = Intention.last_bid(current_anonymous_or_user.id) + 1
	    @intention = Intention
	    	.available(@shop.id, current_anonymous_or_user.id)
	      .first_or_create({
	        title: @promotion.title,
	        supplier_id: @shop.id,
	        buyer_id: current_anonymous_or_user.id,
	        bid: bid
	      })

	    @intention.items.add_promotion(@promotion)
	  end
	end

	private

	def my_chat?
		@chat.owner_id == current_anonymous_or_user.id
	end

  def other_side
    if @intention.buyer_id == current_anonymous_or_user.id
      @intention.seller_id || @intention.supplier.owner_id
    else
      @intention.buyer_id
    end
  end
end
