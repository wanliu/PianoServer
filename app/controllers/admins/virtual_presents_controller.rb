class Admins::VirtualPresentsController < Admins::BaseController
  before_action :set_virtual_present, only: [:show, :update, :destroy]

  # GET /virtual_presents
  # GET /virtual_presents.json
  def index
    @virtual_presents = VirtualPresent.all

    render json: @virtual_presents
  end

  # GET /virtual_presents/1
  # GET /virtual_presents/1.json
  def show
    render json: @virtual_present
  end

  # POST /virtual_presents
  # POST /virtual_presents.json
  def create
    @virtual_present = VirtualPresent.new(virtual_present_params)

    if @virtual_present.save
      render json: @virtual_present, status: :created, location: @virtual_present
    else
      render json: @virtual_present.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /virtual_presents/1
  # PATCH/PUT /virtual_presents/1.json
  def update
    @virtual_present = VirtualPresent.find(params[:id])

    if @virtual_present.update(virtual_present_params)
      head :no_content
    else
      render json: @virtual_present.errors, status: :unprocessable_entity
    end
  end

  # DELETE /virtual_presents/1
  # DELETE /virtual_presents/1.json
  def destroy
    @virtual_present.destroy

    head :no_content
  end

  private

    def set_virtual_present
      @virtual_present = VirtualPresent.find(params[:id])
    end

    def virtual_present_params
      params.require(:virtual_present).permit(:price)
    end
end
