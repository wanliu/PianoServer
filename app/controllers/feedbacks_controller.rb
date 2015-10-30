class FeedbacksController < ApplicationController
  def index
    @feedbacks = Feedback.all
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.is_show = true

    if @feedback.save
      flash[:notice] = "感谢您的反馈, 我们将努力做得更好!"
      redirect_to :action => :index
    else
      render :new
    end
  end

  def update
    @feedback = Feedback.find(params[:id])
    @feedback.update(feedback_params)

    redirect_to feedback_url(@feedback)

  end

  private

  def feedback_params
    params.require(:feedback).permit(:name, :mobile, :information)
  end
end
