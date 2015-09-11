class PromotionsController < ApplicationController
  include DefaultAssetHost
  include ContentManagementService::ContentController

  before_action :set_promotion, only: [:show, :update, :destroy, :chat, :shop]

  register_render_template :homepage_header, only: [ :index ]

  respond_to :json, :html
  # GET /promotions
  # GET /promotions.json
  def index
    @promotions = Promotion.find(:all, from: :active, params: query_params).to_a
  end

  # GET /promotions/1
  # GET /promotions/1.json
  def show
    @promotion.punch request
    @shop = Shop.find(@promotion.shop_id)
  end

  def shop
    @shop = Shop.find(params[:shop_id])
    redirect_to owner_promotion_rooms_path(@promotion, @shop.owner_id)
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
