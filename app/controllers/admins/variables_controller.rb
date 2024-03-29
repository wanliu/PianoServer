class Admins::VariablesController < Admins::BaseController
  before_action :set_parents

  rescue_from ActiveRecord::RecordInvalid, with: :raise_validates_errors

  def show

  end

  def new
    @promotions = Promotion.find(:all, from: :active, params: query_params)

    render :new, layout: false
  end

  def new_promotion_variable
    @variable = PromotionVariable.new

    @promotions = Promotion.find(:all, from: :active, params: query_params)

    render :new_promotion_variable, layout: false
  end

  def new_promotion_set_variable
    @variable = PromotionSetVariable.new

    @promotions = Promotion.find(:all, from: :active, params: query_params)

    render :new_promotion_set_variable, layout: false
  end

  def new_item_variable
    @variable = ItemVariable.new

    @items = []

    render :new_item_variable, layout: false
  end

  def new_item_set_variable
    @variable = ItemSetVariable.new

    @items = []

    render :new_item_set_variable, layout: false
  end

  def search_promotion
    params[:statuses] = [ "Published", "Active", "Finish" ]
    @promotions = Promotion.find(:all, params: query_params)

    render :show, formats: [:json]
  end


  def search_item
    q = params[:q]

    if q.to_i == 0
      @items = Item.with_shop_or_product(q)
    else
      item = Item.where(id: q).first
      @items = if item.nil? then [] else [item] end
    end

    render :show_item, formats: [:json]
  end

  def create
    case variable_params[:type]
    when "promotion_variable", "promotion_set_variable"
      params_name = "#{variable_params[:type]}_params".to_sym
      create_params = send(params_name)
      create_params.merge! type: variable_params[:type].classify
      klass = variable_params[:type].classify.safe_constantize

      if klass
        @variable = klass.new(create_params)
        @variable.host = @host

        @variable.save!

        render json: @variable
      end
    when "item_variable", "item_set_variable"
      params_name = "#{variable_params[:type]}_params".to_sym
      create_params = send(params_name)
      create_params.merge! type: variable_params[:type].classify
      klass = variable_params[:type].classify.safe_constantize

      if klass
        @variable = klass.new(create_params)
        @variable.host = @host

        @variable.save!

        render json: @variable
      end
    else

    end
  end

  def edit
    @variable = Variable.find(params[:id])

    type = @variable[:type].underscore
    @promotions = nil
    @variablePromotions = nil

    case type
    when "promotion_variable"
      @promotion = Promotion.find(@variable.promotion_id) unless @variable.promotion_id.nil?
      @promotions = Promotion.find(:all, from: :active, params: query_params)

      render :edit_promotion_variable, layout: false
    when "promotion_set_variable"
      promotion_string = @variable.promotion_string
      @promotions = Promotion.find(:all, from: :active, params: query_params)
      @variablePromotions = (promotion_string || '').split(',').map {|id| Promotion.find(id) }

      render :edit_promotion_set_variable, layout: false
    when "item_variable"
      @item = Item.find(@variable.item_id) unless @variable.item_id.nil?
      @items = []

      render :edit_item_variable, layout: false

    when "item_set_variable"
      items_string = @variable.items_string.split(',')
      @items = Item.where(id: items_string)
      @variableItems= @items

      render :edit_item_set_variable, layout: false
    else

    end
  end

  def update
    case variable_params[:type]
    when "promotion_variable", "promotion_set_variable"
      @variable = Variable.find(params[:id])
      params_name = "#{variable_params[:type]}_params".to_sym
      update_params = send(params_name)
      update_params.delete(:type)
      @variable.update_attributes!(update_params)

      render json: @variable
    when "item_variable", "item_set_variable"
      @variable = Variable.find(params[:id])
      params_name = "#{variable_params[:type]}_params".to_sym
      update_params = send(params_name)
      update_params.delete(:type)
      @variable.update_attributes!(update_params)

      render json: @variable
    else

    end
  end

  def destroy
    @variable = @host.variables.find(params[:id])

    if @variable.destroy
      head :no_content
    else
      render json: @variable.errors, status: :unprocessable_entity
    end
  end

  private

  def set_parents
    @subject = Subject.find(params[:subject_id])

    if params[:host_type]
      host_type = params[:host_type]
      host_id = params["#{host_type.underscore}_id"]
      @host = host_type.constantize.find(host_id)
    end
  end

  def query_params
    @query_params = {
      page: params[:page] || 1,
      category_id: params[:category_id],
      inline: params[:inline],
      q: params[:q],
      statuses: params[:statuses]
    }
  end

  def variable_params
    params[:variable]
  end

  def promotion_variable_params
    params.require(:variable).permit(:id, :type, :name, :promotion_id)
  end

  def promotion_set_variable_params
    params.require(:variable).permit(:id, :type, :name, :promotion_string)
  end

  def item_variable_params
    params.require(:variable).permit(:id, :type, :name, :item_id)
  end

  def item_set_variable_params
    params.require(:variable).permit(:id, :type, :name, :items_string)
  end

  def raise_validates_errors(e)
    variable = e.record
    if variable && !variable.valid?
      errors_hash = Hash[
        variable.errors.map {|name, errors| [name, variable.errors[name].join(',') ] }
      ]

      render json: { errors: {
        text: variable.errors.full_messages.join(','),
        fields: errors_hash
      }}, status: 422
    end
  end
end
