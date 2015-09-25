class Admins::UnitsController < Admins::BaseController
  before_filter :set_unit, only: [:show, :update, :edit, :destroy]

  def index
    @units = if params[:q].present?
      Unit.where("name LIKE ? OR name LIKE ?", "%#{params[:q]}%")
    else
      Unit.page(params[:page]).per(params[:per])
    end
  end

  def show
    render json: @unit
  end

  def new
    @unit = Unit.new
  end

  def edit
  end

  def create
    @unit = Unit.new(unit_params)

    if @unit.save
      redirect_to admins_units_path
    else
      flash[:errors] = @unit.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @unit.update(unit_params)
      redirect_to admins_units_path
    else
      flash[:error] = @unit.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @unit.destroy

    respond_to do |format|
      format.html { head :no_content }
      format.js
    end
  end

  protected
    def set_unit
      @unit = Unit.find(params[:id])
    end

    def unit_params
      params.require(:unit).permit(:name, :title, :summary)
    end
end
