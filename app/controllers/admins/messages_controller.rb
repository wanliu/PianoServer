class Admins::MessagesController < Admins::BaseController

  def index
    @contacts = Contact.all
    @activities = Admin.system_admin.activities
  end
end
