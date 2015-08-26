class Admins::VariablesController < Admins::BaseController
  before_action :set_parents

  def new
    render :new, layout: false
  end

  def create

  end

  private

  def set_parents
    @subject = Subject.find(params[:subject_id])
    @template = Template.find(params[:template_id])
  end

end
