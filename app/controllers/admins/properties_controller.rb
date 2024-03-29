class Admins::PropertiesController < Admins::BaseController
  before_action :get_property, only: [:show, :edit, :update, :destroy]

  def index
    @properties = Property.order(id: :asc).page(params[:page]).per(params[:per])
  end

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
      flash.now[:error] = @property.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @property.update(property_params)
      redirect_to admins_products_path
    else
      flash.now[:error] = @property.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy

    redirect_to admins_products_path
  end

  def fuzzy_match
    @category = Category.find(params[:category_id])
    @properties = @category.with_upper_properties
    properties = Property.where("title LIKE ? OR name LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    matched_properties = properties - @properties
    render json: { properties: matched_properties }
  end

  private
    def get_property
      @property = Property.find(params[:id])
    end

    def property_params
      params.require(:property).permit(:name, :title, :unit_id, :prop_type, :is_group, :default_value, :validate_rules, :exterior).tap do |whitelisted|
        if Property.map_type? params[:property][:prop_type]
          whitelisted[:map_pairs] =  params[:property][:map_pairs]
        end
      end
    end
end
