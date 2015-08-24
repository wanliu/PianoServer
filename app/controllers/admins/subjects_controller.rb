class Admins::SubjectsController < Admins::BaseController
  def index
    @subjects = Subject.page
  end

  def new
    @subject = Subject.new
  end
end
