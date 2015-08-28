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
    @promotions = Promotion.where("title like ?", "%#{params[:q]}%")


  end

  def create
    case variable_params[:type]
    when "promotion_variable", "promotion_set_variable"
      params_name = "#{variable_params[:type]}_params".to_sym
      create_params = send(params_name)
      create_params.merge! template_id: params[:template_id], type: variable_params[:type].classify
      klass = variable_params[:type].classify.safe_constantize
      @variable = klass.create(create_params) if klass
    else
    end
  end

  private

  def set_parents
    @subject = Subject.unscoped.find(params[:subject_id])
    @template = Template.find(params[:template_id])
  end

  def query_params
    @query_params = {
      page: params[:page] || 1,
      category_id: params[:category_id],
      inline: params[:inline]
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
