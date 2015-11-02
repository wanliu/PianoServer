class Admins::FeedbacksController < Admins::BaseController

  def index
    @feedbacks = Feedback.all.page(params[:page]).per(10).order(id: :desc)
  end
end
