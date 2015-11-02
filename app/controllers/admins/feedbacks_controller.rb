class Admins::FeedbacksController < Admins::BaseController

  def index
    @feedbacks = Feedback.where(is_show: true).page(params[:page]).per(10).order(id: :desc)
  end
end
