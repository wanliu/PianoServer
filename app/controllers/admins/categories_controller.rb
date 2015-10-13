class Admins::CategoriesController < Admins::BaseController
  before_action :get_industry
  before_action :get_category, only: [:properties, :add_property, :update_property, :remove_property, :show_inhibit, :hide_inhibit, :children, :edit, :write_item_desc, :read_item_desc]
  before_action :get_property, only: [:add_property, :update_property, :remove_property]

  respond_to :js, only: [:new_property]

  def show
  end

  def properties
    @properties = @category.properties
  end

  def children
    @categories = @category.children
  end

  def edit
    @properties = @category.with_upper_properties
    @remind_properties = (Property.all - @category.with_upper_properties)
  end

  def category_edit

  end

  def write_item_desc
    @category.item_desc = params[:template]

    render json: {}, status: :ok
  end

  def read_item_desc
    render json: {template: @category.item_desc}, status: :ok
  end

  def show_inhibit
    @properties = @category.with_upper_properties(false)

    respond_to do |format|
      format.js { render :show_inhibit }
    end
  end

  def hide_inhibit
    @properties = @category.with_upper_properties

    respond_to do |format|
      format.js { render :hide_inhibit }
    end
  end

  def add_property
    CategoryProperty.find_or_initialize_by category_id:  params[:id], property_id:  params[:property_id] do |cp|
      cp.state = 0
      cp.save
    end

    respond_to do |format|
      format.js { render :add_property }
    end
  end

  def update_property

  end

  def remove_property
    # conditions = ["UPDATE categories_properties SET state = 1 WHERE categories_properties.category_id = ? and categories_properties.property_id = ?", params[:id] , params[:property_id]]

    # Category.find_by_sql(conditions)

    CategoryProperty.find_or_initialize_by category_id:  params[:id], property_id:  params[:property_id] do |cp|
      cp.state = 1
      cp.save
    end

    respond_to do |format|
      format.js { render :remove_property }
    end
  end

  private

  def get_industry
    @industry = Industry.find(params[:industry_id])
  end

  def get_category
    @category = Category.find(params[:id])
  end

  def get_property
    @property = Property.find(params[:property_id])
  end
end
