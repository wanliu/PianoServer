require 'tempfile'

class Admins::TemplatesController < Admins::BaseController
  include ContentManagementService::Helpers

  before_action :set_templable
  before_action :set_parents
  before_action :set_template, only: [ :update, :upload]
  before_action :set_titles
  before_filter :set_view_path, only: [:preview, :preview_new]
  after_filter :rm_temp_file, only: [ :preview ]

  def new
    @edit_mode = true
    @template = Template.new template_params
    @template_builder_id = params[:template_builder_id]
    respond_to do |format|
      format.js { render :new }
    end
  end

  def index
    @templates = combine @parent.templates, default_templates
    @template = @templates.first
  end

  def search
    @templates = Template
      .where(templable: @templable)
      .with_search(params[:q])

    render :index
  end

  def show
    @templates = combine @parent.templates, default_templates
    @template = @templates.select { |tpl| tpl.name == params[:id] } [0]
  end

  def update
    old_filename = @template.filename

    @template.update_attributes(template_params)

    if @template.valid? && old_filename != @template.filename
      old_path = File.join @parent.path, old_filename
      File.delete(old_path) if File.exist?(old_path)
    end
  end

  def create
    @template = @parent.templates.build(template_params)

    filename = @template.template_path

    FileUtils.mkdir_p File.dirname(filename)
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
        @templates = combine @parent.templates, default_templates

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

  def set_templable
    templable_id = params["#{params[:templable_type].underscore}_id"]
    @templable = params[:templable_type].constantize.find(templable_id)
  end

  def set_titles
    @primary_title = @parent.model_name.human + "&middot;" + @parent.title || @parent.name
    @subject_title = "模版管理"
  end

  def set_parents
    if params[:parents_type] && params[:parents_type].is_a?(Array)
      @parents = params[:parents_type].map do |parent_type|
        parent_id = params["#{parent_type.underscore}_id"]
        parent_type.constantize.find(parent_id)
      end
      @parent = @parents.last
    elsif params[:parent_type]
      parent_type = params[:parent_type]
      parent_id = params["#{parent_type.underscore}_id"]
      @parent = parent_type.constantize.find(parent_id)
      @parents = [ @parent ]
    elsif @templable
      @parent = @templable
      @parents = [ @parent ]
    end
  end

  def set_view_path
    ContentManagementService.set_resource_file_system(@parent, 'views')
  end

  def combine(targets, defaults)
    defaults.map do |tpl|
      targets.select {|t| t.name == tpl.name }[0] || tpl
    end
  end

  def default_templates
    @parent.try(:default_templates) || @parent.templates
  end
end
