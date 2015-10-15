require 'tempfile'

class Admins::TemplatesController < Admins::BaseController
  include ContentManagementService::Helpers

  before_action :set_parent
  before_action :set_template, only: [ :update, :upload]
  before_filter :set_view_path, only: [:preview, :preview_new]
  after_filter :rm_temp_file, only: [ :preview ]

  def show
  end

  def update
    old_filename = @template.filename

    @template.update_attributes(template_params)

    if @template.valid? && old_filename != @template.filename
      old_path = "#{SubjectService.subject_path(@parent)}/#{old_filename}"
      File.delete(old_path) if File.exist?(old_path)
    end
  end

  def create
    @template = @parent.templates.build(template_params)

    filename = @template.template_path
    File.write filename, template_params[:content]

    # generate a name base on filename, and do not repeat in the same subject
    if @template.name.blank?
      name = File.basename(filename)

      while Template.exists?(templable: @parent, name: name)
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
    @template = @parent.templates.find(params[:id])

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

  def set_parent
    templable_id = params["#{params[:templable_type].underscore}_id"]
    @parent = params[:templable_type].constantize.find(templable_id)
  end

  def set_view_path
    ContentManagementService.set_resource_file_system(@parent, 'views')
  end
end
