class Admins::CategoriesController < Admins::BaseController
  before_action :get_industry
  before_action :get_category, only: [:properties, :add_property, :update_property, :remove_property, :show_inhibit, :hide_inhibit, :children, :edit, :write_item_desc, :read_item_desc, :resort]
  before_action :get_property, only: [:add_property, :update_property, :remove_property, :resort]

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
    @templates = @category.templates
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
    cp = CategoryProperty.find_or_initialize_by category_id:  params[:id], property_id:  params[:property_id]
    cp.update(state: 0)

    respond_to do |format|
      format.js { render :add_property }
    end
  end

  def resort
    cp_list = @category.sorted_category_properties
    # cp_list = CategoryProperty.where(category_id: params[:id], property_id: property_ids).order(:sortid).to_a
    @cp = CategoryProperty.where(category_id:  params[:id], property_id:  params[:property_id]).first

    _start = cp_list.index { |_cp| _cp.property_id == @cp.property_id }
    _end = _start + params[:index].to_i

    if _start > _end
      min = cp_list[_end].sortid
      cp_list[_end..._start].each do |cp|
        cp.sortid += 1
        cp.save
      end
      @cp.sortid = min
      @cp.save
    else
      max = cp_list[_end].sortid
      cp_list[_start+1.._end].each do |cp|
        cp.sortid -= 1
        cp.save
      end
      @cp.sortid = max
      @cp.save
    end
  end

  def update_property

  end

  def remove_property
    # conditions = ["UPDATE categories_properties SET state = 1 WHERE categories_properties.category_id = ? and categories_properties.property_id = ?", params[:id] , params[:property_id]]

    # Category.find_by_sql(conditions)


    cp = CategoryProperty.find_or_initialize_by category_id:  params[:id], property_id:  params[:property_id]
    cp.update(state: 1)

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
