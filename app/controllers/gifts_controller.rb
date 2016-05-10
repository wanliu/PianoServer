class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :update, :destroy]

  # GET /gifts
  # GET /gifts.json
  def index
    @gifts = Gift.all

    render json: @gifts
  end

  # GET /gifts/1
  # GET /gifts/1.json
  def show
    render json: @gift
  end

  # POST /gifts
  # POST /gifts.json
  def create
    @gift = Gift.new(gift_params)

    if @gift.save
      render json: @gift, status: :created, location: @gift
    else
      render json: @gift.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /gifts/1
  # PATCH/PUT /gifts/1.json
  def update
    @gift = Gift.find(params[:id])

    if @gift.update(gift_params)
      head :no_content
    else
      render json: @gift.errors, status: :unprocessable_entity
    end
  end

  # DELETE /gifts/1
  # DELETE /gifts/1.json
  def destroy
    @gift.destroy

    head :no_content
  end

  private

    def set_gift
      @gift = Gift.find(params[:id])
    end

    def gift_params
      params.require(:gift).permit(:item_id, :present_id, :quantity, :total)
    end
end
