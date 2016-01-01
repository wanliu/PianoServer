class PromotionsController < ApplicationController
  include DefaultAssetHost

  before_action :set_promotion, only: [:show, :update, :destroy, :chat, :shop, :toggle_follow]

  caches_action :index, expires_in: 5.minutes, layout: false, cache_path: Proc.new { |request|
    { etag: @subject.updated_at.utc } if @subject.present?
  }

  respond_to :json, :html

  # GET /promotions
  # GET /promotions.json
  # 如果存在有效主题，@promotions就不需要获取
  def index
    @promotions = if current_subject.present?
      []
    else
      Promotion.find(:all, from: :active, params: query_params).to_a
    end

    render :homepage, with: @subject
  end

  # GET /promotions/1
  # GET /promotions/1.json
  def show
    self.page_title = [ @promotion.title ]
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

  def toggle_follow
    action = "关注"

    if current_user.present?
      if current_user.follows? @promotion
        current_user.unfollows! @promotion
        action = "取消关注"
      else
        current_user.follows! @promotion
      end

      render json: { sucess: "#{action}成功！" }, status: :ok
    else
      render json: { errors: ["匿名用户无法进行此类操作，请登录后再试"] }, status: :unprocessable_entity
    end
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
        per: params[:page] || 24,
        category_id: params[:category_id],
        inline: params[:inline]
      }
    end
end
