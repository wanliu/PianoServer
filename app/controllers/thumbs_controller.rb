class ThumbsController < ApplicationController
  before_action :set_thumb, only: [:show, :update, :destroy]

  # GET /thumbs
  # GET /thumbs.json
  def index
    @thumbs = Thumb.all

    render json: @thumbs
  end

  # GET /thumbs/1
  # GET /thumbs/1.json
  def show
    render json: @thumb
  end

  # POST /thumbs
  # POST /thumbs.json
  def create
    @thumb = Thumb.new(thumb_params)

    if @thumb.save
      render json: @thumb, status: :created, location: @thumb
    else
      render json: @thumb.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /thumbs/1
  # PATCH/PUT /thumbs/1.json
  def update
    @thumb = Thumb.find(params[:id])

    if @thumb.update(thumb_params)
      head :no_content
    else
      render json: @thumb.errors, status: :unprocessable_entity
    end
  end

  # DELETE /thumbs/1
  # DELETE /thumbs/1.json
  def destroy
    @thumb.destroy

    head :no_content
  end

  private

    def set_thumb
      @thumb = Thumb.find(params[:id])
    end

    def thumb_params
      params.require(:thumb).permit(:user_id, :thumbable_id, :thumbable_type)
    end
end
