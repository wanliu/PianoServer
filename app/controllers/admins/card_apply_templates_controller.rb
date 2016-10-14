class Admins::CardApplyTemplatesController < Admins::BaseController
  before_action :set_template, only: [:show, :edit, :update, :destroy, :add_item, :remove_item]

  def index
    @templates = CardApplyTemplate.includes(:items).order(id: :desc)
      .page(params[:page])
      .per(params[:per])

    @template = CardApplyTemplate.new
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @template = CardApplyTemplate.new(template_params)

    respond_to do |format|
      if @template.save
        format.js
        format.html { redirect_to admins_card_apply_templates_path }
        format.json { render json: @template }
      else
        format.html do
          flash[:error] = @template.errors.full_messages.join(", ")
          redirect_to new_admins_card_apply_template_path
        end

        format.json do
          render json: {errors: @template.errors.full_messages.join(", ")}, status: :unprocessable_entity
        end

        format.js
      end
    end
  end

  def update
    if @template.update(template_params)
      redirect_to admins_card_apply_templates_path
    else
      flash[:error] = @template.errors.full_messages.join(', ')
      render "edit"
    end
  end

  def add_item
  end

  def remove_item
  end

  def destroy
    @template.destroy
  end

  private

  def set_template
    @template = CardApplyTemplate.find(params[:id])
  end

  def template_params
    params.require(:card_apply_template).permit(:title, :apply_items, card_template_items_attributes: [:item_id])
  end
end
