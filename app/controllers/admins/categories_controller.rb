class Admins::CategoriesController < Admins::BaseController
  before_action :get_industry
  before_action :get_category, only: [:show, :properties, :update_property, :remove_property, :show_inhibit, :hide_inhibit]
  before_action :get_property, only: [:add_property, :update_property, :remove_property]

  respond_to :js, only: [:new_property]

  def show
    # @industry.category.find()
    @categories = @category.children
    @properties = @category.with_upper_properties
    @remind_properties = (Property.all - @category.with_upper_properties)
  end

  def properties
    @properties = @category.properties
  end

  def category_edit

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
    conditions = [ "categories_properties.category_id = ? and categories_properties.property_id = ?", params[:id] , params[:property_id] ]

    if Category.joins(:properties).exists?(conditions)
      Category.joins(:properties).update_all("categories_properties.state = 1", conditions)
    else
      get_category.properties.push(@property)
    end

    respond_to do |format|
      format.js { render :add_property }
    end
  end

  def update_property

  end

  def remove_property
    conditions = ["UPDATE categories_properties SET state = 1 WHERE categories_properties.category_id = ? and categories_properties.property_id = ?", params[:id] , params[:property_id]]

    Category.find_by_sql(conditions)

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
