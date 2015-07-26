class Admins::ContactsController < Admins::BaseController
  def index
    @contacts = Contact.all
  end
end
