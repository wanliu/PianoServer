class Admins::VariablesController < Admins::BaseController
  before_action :set_parents

  def new
    @promotions = Promotion.find(:all, from: :active, params: query_params)

    render :new, layout: false
  end

  def create

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
      inline: params[:inline]
    }
  end
end
