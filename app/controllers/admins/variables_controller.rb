class Admins::VariablesController < Admins::BaseController
  before_action :set_parents

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

  def search_promotion
    @promotions = Promotion.find(:all, params: query_params)

    render :show, formats: [:json]
  end

  def create
    case variable_params[:type]
    when "promotion_variable", "promotion_set_variable"
      params_name = "#{variable_params[:type]}_params".to_sym
      create_params = send(params_name)
      create_params.merge! template_id: params[:template_id], type: variable_params[:type].classify
      klass = variable_params[:type].classify.safe_constantize
      @variable = klass.create(create_params) if klass

      render json: @variable
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
      @variable.update_attributes(update_params)

      render json: @variable
    else

    end
  end

  def destroy
    @variable = @template.variables.find(params[:id])

    if @variable.destroy
      head :no_content
    else
      render json: @variable.errors, status: :unprocessable_entity
    end
  end

  private

  def set_parents
    @subject = Subject.find(params[:subject_id])
    @template = Template.find(params[:template_id])
  end

  def query_params
    @query_params = {
      page: params[:page] || 1,
      category_id: params[:category_id],
      inline: params[:inline],
      q: params[:q]
    }
  end

  def variable_params
    params[:variable]
  end

  def promotion_variable_params
    params.require(:variable).permit(:id, :type, :name, :promotion_id, :template_id)
  end

  def promotion_set_variable_params
    params.require(:variable).permit(:id, :type, :name, :promotion_string, :template_id)
  end
end
