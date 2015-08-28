class Admins::AttachmentsController < Admins::BaseController
  before_action :set_attachment, only: [ :destroy, :update ]
  respond_to :js

  def update
    @attachment.update_attributes(attachment_params)
    render json: @attachment
  end

  def destroy
    @attachment.destroy
  end

  private

  def set_attachment
    @attachment = Attachment.find(params[:id])
  end

  def attachment_params
    params.require(:attachment).permit(:name)
  end
end
