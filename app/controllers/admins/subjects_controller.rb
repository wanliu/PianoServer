class Admins::SubjectsController < Admins::BaseController

  before_action :set_subject, only: [:edit, :show, :update, :destroy]
  def index
    @subjects = Subject.page
  end

  def new
    @subject = Subject.new
  end

  def create
    @subject = Subject.create subject_params
    redirect_to admins_subjects_path
  end

  def update
    @subject.update_attributes(subject_params)
    redirect_to admins_subjects_path # (@subject)
  end


  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:title, :description, :start_at, :end_at)
  end
end
