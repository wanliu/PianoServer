class PromotionsController < ApplicationController
  include DefaultAssetHost
  before_action :set_promotion, only: [:show, :update, :destroy, :chat]

  respond_to :json, :html
  # GET /promotions
  # GET /promotions.json
  def index
    @promotions = Promotion.find(:all, from: :active, params: query_params)
  end

  # GET /promotions/1
  # GET /promotions/1.json
  def show
    @promotion
    @shop = Shop.find(@promotion.shop_id)
  end

  def chat
    @promotion
    @shop = Shop.find(@promotion.shop_id)
    bid = Order.last_bid(current_anonymous_or_user.id) + 1
    @order = Order
      .where(supplier_id: @shop.id, buyer_id: current_anonymous_or_user.id)
      .first_or_create({
        title: @promotion.title,
        supplier_id: @shop.id, 
        buyer_id: current_anonymous_or_user.id, 
        bid: bid
      })
    @order.items.add_promotion(@promotion)
    pp @order
    # @order = 
  end

  # POST /promotions
  # POST /promotions.json
  def create
    @promotion = Promotion.new(promotion_params)

    if @promotion.save
      render json: @promotion, status: :created, location: @promotion
    else
      render json: @promotion.errors, status: :unprocessable_entity
    end
  end

  def status
    @order = Order.find(params[:order_id])
    response = {
      state: @order.state
    }
    
    response.merge!(url: @order.avatar_url) if @order.state == :done or @order.state == "done"

    respond_to do |format|
      format.json do 
        render json: response
      end
    end
  end

  # PATCH/PUT /promotions/1
  # PATCH/PUT /promotions/1.json
  def update
    @promotion = Promotion.find(params[:id])

    if @promotion.update(promotion_params)
      head :no_content
    else
      render json: @promotion.errors, status: :unprocessable_entity
    end
  end

  # DELETE /promotions/1
  # DELETE /promotions/1.json
  def destroy
    @promotion.destroy

    head :no_content
  end

  def favorited
    
  end

  def saled_product_count

  end

  private

    def set_promotion
      @promotion = Promotion.find(params[:id])
    end

    def promotion_params
      params[:promotion]
    end

    def query_params
      @query_params = {
        page: params[:page] || 1,
        category_id: params[:category_id],
        inline: params[:inline]
      }
    end
end
