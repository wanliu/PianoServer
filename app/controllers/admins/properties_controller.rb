class Admins::PropertiesController < Admins::BaseController
  before_action :get_property, only: [:show, :edit, :update, :destroy]

  def new
    @property = Property.new
  end

  def edit
  end

  def create
    @property = Property.new(property_params)

    if @property.save
      redirect_to admins_products_path
    else
      flash[:error] = @property.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @property.update(property_params)

    if @property.valid?
      redirect_to admins_products_path
    else
      flash[:error] = @property.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy

    redirect_to admins_products_path
  end

  private
    def get_property
      @property = Property.find(params[:id])
    end

    def property_params
      params.require(:property).permit(:name, :title, :prop_type)
    end
end