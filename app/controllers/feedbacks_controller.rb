class FeedbacksController < ApplicationController
  before_action :set_feedbacks_title

  def index
    @feedbacks = Feedback.where(is_show: true).page(params[:page]).order(id: :desc)
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      flash[:notice] = "感谢您的反馈, 我们将努力做得更好!"
      redirect_to :action => :index
    else
      render :new
    end
  end

  def update
    @feedback = Feedback.find(params[:id])
    @feedback.update_attributes(feedback_params)
    
    respond_to do |format|
      format.json { render json: {sucess: true} }
    end
  end

  private

  def set_feedbacks_title
    set_page_title '用户反馈'
  end

  def feedback_params
    params.require(:feedback).permit(:name, :mobile, :information, :reply, :is_show)
  end
end
