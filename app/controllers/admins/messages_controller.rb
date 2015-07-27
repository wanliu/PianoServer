class Admins::MessagesController < Admins::BaseController

  def index
    @contacts = Contact.all
  end
end
