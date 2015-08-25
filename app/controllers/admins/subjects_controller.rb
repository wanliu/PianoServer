class Admins::SubjectsController < Admins::BaseController

  before_action :set_subject, only: [:edit, :show, :update, :destroy]
  def index
    @subjects = Subject.page
  end

  def new
    @subject = Subject.new
    defaults_templates.each do |template|
      @subject.templates.build template
    end
  end

  def create
    @subject = Subject.create subject_params
    redirect_to admins_subject_path(@subject)
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

  def defaults_templates
    [
      {
        name: :_homepage_header,
        filename: 'views/_homepage_header.html.liquid',
        content: default_template_content('views/_homepage_header.html.liquid')
      },
      {
        name: :index,
        filename: 'views/index.html.liquid',
        content: default_template_content('views/index.html.liquid')
      },
    ]
  end

  def default_template_content(filename)
    File.read Rails.root.join('lib/generators/subject/templates', filename)
  end
end
