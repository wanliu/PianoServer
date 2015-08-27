require 'tempfile'

class Admins::TemplatesController < Admins::BaseController
  include ConcernParentResource

  after_filter :rm_temp_file, only: [ :preview ]

  set_parent_param :subject_id

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

  def preview
    @subject = Subject.find(params[:subject_id])
    @template = @subject.templates.find(params[:id])

    source = params[:source]
    @file = Tempfile.new(['template', '.html.liquid'], "#{Rails.root}/tmp/")
    @file.write source
    @file.rewind

    render file: @file.path, layout: false
  end

  def preview_new
    @subject = Subject.find(params[:subject_id])

    source = params[:source]
    @file = Tempfile.new(['template', '.html.liquid'], "#{Rails.root}/tmp/")
    @file.write source
    @file.rewind

    render file: @file.path, layout: false
  end


  private

  def template_params
    params.require(:template).permit(:name, :filename, :content)
  end

  def rm_temp_file
    @file.close!
  end
end
