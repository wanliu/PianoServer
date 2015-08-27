class Admins::TemplatesController < Admins::BaseController
  include ConcernParentResource
  set_parent_param :subject_id

  before_action :set_template, only: [:preview, :update, :upload]

  def update
    @template.update_attributes(template_params)
  end


  def upload
    # filename = params[:file].original_filename
    @attachment = @template.attachments.create(name: params[:file].original_filename, filename: params[:file])

    render json: { success: true, url: @attachment.filename.url(:avatar) }
  end


  private

  def template_params
    params.require(:template).permit(:name, :filename, :content)
  end

  def set_template
    @template = @parent.templates.find(params[:id])
  end

end
