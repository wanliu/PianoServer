class Admins::AttachmentsController < Admins::BaseController
  before_action :set_attachment, only: [ :destroy ]
  respond_to :js

  def update
    @attachment.update_attributes(attachment_params)
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
