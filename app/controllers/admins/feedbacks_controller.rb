class Admins::FeedbacksController < Admins::BaseController

  def index
    @feedbacks = Feedback.all.page(params[:page]).per(5)
  end
end
