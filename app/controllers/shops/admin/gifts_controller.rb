class Shops::Admin::GiftsController < Shops::Admin::BaseController
  before_action :set_item
  before_action :set_gift, only: [:show, :update, :destroy]

  def index
  end

  def show
  end

  def create
    @gift = @item.gifts.build(gift_params)

    if @gift.save
      render json: @gift.as_json(methods: [:title, :cover_url, :properties_title, :current_stock]), status: :created
    else
      render json: {error: @gift.errors.full_messages.join(', ')}, status: :unprocessable_entity
    end
  end

  def update
    if @gift.update(gift_update_params)
      render json: @gift.as_json(methods: [:title, :cover_url, :properties_title])
    else
      render json: { error: @gift.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy
    @gift.destroy

    # head :no_content
    flash[:notice] = "删除礼品成功"
    redirect_to edit_shop_admin_item_path(@shop.name, @item)
  end

  private

  def set_item
    @item = @shop.items.find(params[:item_id])
  end

  def set_gift
    @gift = @item.gifts.find(params[:id])
  end

  def gift_params
    params.require(:gift)
      .permit(:present_id, :quantity, :total)
      .tap do |white_list|
        if params[:gift][:properties].present?
          white_list[:properties] = params[:gift][:properties]
        end
    end
  end

  def gift_update_params
    params.require(:gift).permit(:present_id, :quantity, :total)
  end
end