class Shops::Admin::ExpressTemplatesController < Shops::Admin::BaseController
  before_action :set_express_template, only: [:show, :edit, :update, :destroy]

  # GET /express_templates
  # GET /express_templates.json
  def index
    @express_templates = current_shop.express_templates
      .page(params[:page])
      .per(params[:per])

    # render json: @express_templates
  end

  def new
    @express_template = current_shop.express_templates
      .build(free_shipping: false, template: {
        default: { first_quantity: 1 }
      })
  end

  # GET /express_templates/1
  # GET /express_templates/1.json
  def show
    # render json: @express_template
  end

  def edit
  end

  # POST /express_templates
  # POST /express_templates.json
  def create
    @express_template = current_shop.express_templates.build(express_template_params)

    respond_to do |format|
      if @express_template.save
        format.html do
          flash[:notice] = "成功创建运费模板\"#{@express_template.name}\"！"
          redirect_to shop_admin_express_templates_path(current_shop.name)
        end
        format.json { render json: @express_template, status: :created }
      else
        format.html { render "edit" }
        format.json { render json: @express_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /express_templates/1
  # PATCH/PUT /express_templates/1.json
  def update
    @express_template = current_shop.express_templates.find(params[:id])

    respond_to do |format|
      if @express_template.update(express_template_params)
        format.html do
          flash[:notice] = "成功保存运费模板\"#{@express_template.name}\"！"
          redirect_to shop_admin_express_templates_path(current_shop.name)
          # redirect_to shop_admin_express_template_path(current_shop.name, @express_template) }
        end
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @express_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /express_templates/1
  # DELETE /express_templates/1.json
  def destroy
    @express_template.destroy

    respond_to do |format|
      format.html { redirect_to shop_admin_express_templates_path(current_shop.name) }
      format.json { head :no_content }
    end
  end

  def next_nodes
    list = ChinaCity.list(params[:code])
    render json: list
  end

  private

    def set_express_template
      @express_template = current_shop.express_templates.find(params[:id])
    end

    def express_template_params
      params.require(:express_template)
        .permit(:shop_id, :name, :free_shipping)
        .tap do |white_list|
          template = params[:express_template][:template]

          if template.present?
            white_list[:template] = {}

            template.each do |code, setting|
              if "default" == code || (ChinaCity.get(code) rescue false)
                white_list[:template][code] = template[code]
              end
            end
          end
        end
    end
end
