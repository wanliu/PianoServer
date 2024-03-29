class Admins::SubjectsController < Admins::BaseController

  before_action :set_subject, only: [:edit, :show, :update, :destroy, :upload]
  before_action :authen_piano_token, only: :touch_current
  skip_before_action :authenticate_admin!, :verify_authenticity_token, 
                     :current_industry, :set_current_cart, :prepare_system_view_path, 
                     :set_locale, :set_meta_user_data, only: :touch_current

  def index
    @subjects = Subject.order(id: :desc).page(params[:page]).per(params[:per])
  end

  def new
    @subject = Subject.new
    # defaults_templates.each do |template|
    #   @subject.templates.build template
    # end
  end

  def edit
    @new_template = Template.new(filename: "views/undefined.html.liquid", content: '')
  end

  def create
    @subject = Subject.create subject_params
    SubjectService.build @subject.name
    redirect_to edit_admins_subject_path(@subject)
  end

  def update
    @subject.update_attributes(subject_params)

    if request.xhr?
      render json: @subject
    else
      redirect_to admins_subjects_path # (@subject)
    end
  end

  def upload

  end

  def destroy
    if @subject.destroy 
      redirect_to admins_subjects_path, notice: "主题'#{@subject.title}'已经成功删除！"
    else
      redirect_to admins_subjects_path, flash: { error: @subject.errors.full_messages.join('，') }
    end
  end

  def touch_current
    current_subject.try(:touch)

    head :ok
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:title, :description, :start_at, :end_at, :status)
  end

  def defaults_templates
    [
      {
        name: :_homepage_header,
        filename: 'views/promotions/_homepage_header.html.liquid',
        content: default_template_content('views/promotions/_homepage_header.html.liquid')
      },
      {
        name: :index,
        filename: 'views/subjects/index.html.liquid',
        content: default_template_content('views/subjects/index.html.liquid')
      },
    ]
  end

  def default_template_content(filename)
    File.read Rails.root.join('lib/generators/subject/templates', filename)
  end

  def authen_piano_token
    subject_touch_token = Settings.wanliu.subject_touch_token

    unless Devise.secure_compare(params[:token], subject_touch_token)
      head :not_found
    end
  end
end
