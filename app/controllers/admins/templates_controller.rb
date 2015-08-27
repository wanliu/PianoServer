class Admins::TemplatesController < Admins::BaseController
  include ConcernParentResource

  set_parent_param :subject_id

  def preview
    @template = @parent.templates.find(params[:id])

  end

  def update
    @template = @parent.templates.find(params[:id])
    @template.update_attributes(template_params)
  end


  private

  def template_params
    params.require(:template).permit(:name, :filename, :content)
  end

end
