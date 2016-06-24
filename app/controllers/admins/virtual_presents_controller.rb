class Admins::VirtualPresentsController < Admins::BaseController
  before_action :set_virtual_present, only: [:show, :update, :destroy]

  # GET /virtual_presents
  # GET /virtual_presents.json
  def index
    @virtual_presents = VirtualPresent.order(id: :desc).page(params[:page]).per(params[:per])
    @virtual_present  = VirtualPresent.new(price: 0)
    # render json: @virtual_presents
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

    respond_to do |format|
      if @virtual_present.save
        format.js
        format.html
        format.json { render json: @virtual_present, status: :created, location: @virtual_present }
      else
        format.js
        format.html
        format.json { render json: @virtual_present.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /virtual_presents/1
  # PATCH/PUT /virtual_presents/1.json
  def update
    @virtual_present = VirtualPresent.find(params[:id])

    respond_to do |format|
      if @virtual_present.update(virtual_present_update_params)
        format.js
        format.html { head :no_content }
        format.json { render json: {} }
      else
        format.js
        render json: @virtual_present.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /virtual_presents/1
  # DELETE /virtual_presents/1.json
  def destroy
    @virtual_present.destroy

    respond_to do |format|
      format.js
      format.html { head :no_content }
      format.json { head :no_content }
    end
  end

  private

    def set_virtual_present
      @virtual_present = VirtualPresent.find(params[:id])
    end

    def virtual_present_params
      params.require(:virtual_present).permit(:name, :price, :value, :title)
    end

    def virtual_present_update_params
      params.require(:virtual_present).permit(:price, :value, :title)
    end
end
