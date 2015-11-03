class Admins::FeedbacksController < Admins::BaseController

  def index
    @feedbacks = Feedback.all.page(params[:page]).order(id: :desc)
  end
end
