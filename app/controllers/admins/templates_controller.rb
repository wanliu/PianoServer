class Admins::TemplatesController < Admins::BaseController
  include ConcernParentResource

  set_parent_param :subject_id

  def preview
    @template = @parent.templates.find(params[:id])

  end

  def show
  end

  def update
    @template = @parent.templates.find(params[:id])
    @template.update_attributes(template_params)
  end

  def create
    @subject = Subject.find(params[:subject_id])
    @template = @subject.templates.build(template_params)

    filename = "#{Settings.sites.system.root}/subjects/#{@subject.name}/#{@template.filename}"
    File.write filename, template_params[:content]

    # generate a name base on filename, and do not repeat in the same subject
    if @template.name.blank?
      name = File.basename(filename)

      while Template.exists?(subject_id: @subject, name: name)
        name.succ!
      end

      @template.name = name
    end

    respond_to do |format|
      if @template.save
        format.html { render :show, layout: false }
        format.js { render :show, layout: false, status: :created }
        format.json  { render json: {}, status: :created }
      else
        format.html { render :new }
        format.json { render json: @tamplate.errors, status: :unprocessable_entity }
      end
    end
  end


  private

  def template_params
    params.require(:template).permit(:name, :filename, :content)
  end

end
