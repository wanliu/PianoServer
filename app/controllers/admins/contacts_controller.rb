class Admins::ContactsController < Admins::BaseController
  def index
    @contacts = Contact.all
  end

  def update
  	@contact = Contact.find(params[:id])
  	@contact.create_status(state: :done)
  	render :update
  end
end
