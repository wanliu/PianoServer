require 'tempfile'

class Admins::TemplatesController < Admins::BaseController
  include ConcernParentResource # 废弃 请使用 ParentResource
  include ContentManagementService::Methods
  include SubjectsHelper

  set_parent_param :subject_id
  before_action :set_template, only: [ :update, :upload]
  before_filter :set_subject_and_view_path, only: [:preview, :preview_new]
  after_filter :rm_temp_file, only: [ :preview ]

  def show
  end

  def update
    old_filename = @template.filename
    @subject = Subject.find(params[:subject_id])

    @template.update_attributes(template_params)

    if @template.valid? && old_filename != @template.filename
      old_path = "#{SubjectService.subject_path(@subject)}/#{old_filename}"
      File.delete(old_path) if File.exist?(old_path)
    end
  end

  def create
    @subject = Subject.find(params[:subject_id])
    @template = @subject.templates.build(template_params)

    filename = "#{SubjectService.subject_path(@subject)}/#{@template.filename}"
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
    @template = @subject.templates.find(params[:id])

    load_all_variables @template.variables
    load_attachments

    source = params[:source]
    @file = Tempfile.new(["template", ".html.liquid"], "#{Rails.root}/tmp/")
    @file.write source
    @file.rewind

    render file: @file.path, layout: "preview"
  end

  def preview_new
    source = params[:source]
    @file = Tempfile.new(["template", ".html.liquid"], "#{Rails.root}/tmp/")
    @file.write source
    @file.rewind

    render file: @file.path, layout: "preview"
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

  def set_subject_and_view_path
    @subject = Subject.find(params[:subject_id])
    set_file_system(@subject)
  end
end
