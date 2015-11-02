class Admins::MessagesController < Admins::BaseController

  def index
    @contacts = Contact.all
    @activities = Admin.system_admin.activities

    @feedbacks = Feedback.all.page(params[:page]).per(10)
  end
end
