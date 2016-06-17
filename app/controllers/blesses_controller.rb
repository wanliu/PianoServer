class BlessesController < ApplicationController
  before_action :set_bless, only: [:show, :update, :destroy]

  # GET /blesses
  # GET /blesses.json
  def index
    @blesses = Bless.all

    render json: @blesses
  end

  # GET /blesses/1
  # GET /blesses/1.json
  def show
    render json: @bless
  end

  # POST /blesses
  # POST /blesses.json
  def create
    @bless = Bless.new(bless_params)

    if @bless.save
      render json: @bless, status: :created, location: @bless
    else
      render json: @bless.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /blesses/1
  # PATCH/PUT /blesses/1.json
  def update
    @bless = Bless.find(params[:id])

    if @bless.update(bless_params)
      head :no_content
    else
      render json: @bless.errors, status: :unprocessable_entity
    end
  end

  # DELETE /blesses/1
  # DELETE /blesses/1.json
  def destroy
    @bless.destroy

    head :no_content
  end

  private

    def set_bless
      @bless = Bless.find(params[:id])
    end

    def bless_params
      params.require(:bless).permit(:sender_id, :virtual_present_id, :message, :birthday_party_id)
    end
end
