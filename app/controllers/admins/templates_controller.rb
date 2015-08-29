require 'tempfile'

class Admins::TemplatesController < Admins::BaseController
  include ConcernParentResource
  include ContentManagementService::Methods


  set_parent_param :subject_id
  after_filter :rm_temp_file, only: [ :preview ]
  before_action :set_template, only: [ :update, :upload]

  def show
  end

  def update
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

    @template.variables.each do |variable|
      name = '@' + variable.name
      self.instance_variable_set name.to_sym, variable.call if variable.respond_to?(:call)
    end

    load_attachments

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


  def upload
    # filename = params[:file].original_filename
    @attachment = @template.attachments.create(name: params[:file].original_filename, filename: params[:file])

    render :upload, formats: [:json]
  end


  private

  def template_params
    params.require(:template).permit(:name, :filename, :content)
  end

  def rm_temp_file
    @file.close!
  end

  def set_template
    @template = @parent.templates.find(params[:id])
  end
end
