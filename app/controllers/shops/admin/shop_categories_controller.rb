class Shops::Admin::ShopCategoriesController < Shops::Admin::BaseController
  before_action :is_descendant_of_category, only: [:show_by_child, :update_by_child, :upload_image,
    :destroy_by_child, :edit, :update_category]
  before_action :set_paginating, only: [:show, :show_by_child]

  def create
    @root = @shop.shop_category
    @shop_category = @root.children.create(shop_category_params)

    render :show, formats: [ :json ]
  end

  def create_by_child
    @root = @shop.shop_category
    @parent = ShopCategory.find(params[:parent_id])
    raise ActionController::RoutingError.new('Not Found') unless @parent.is_or_is_descendant_of?(@root)
    @shop_category = @parent.children.build(shop_category_params)

    respond_to do |format|
      format.json do
        if @shop_category.save
          render :show, formats: [ :json ]
        else
          render json: { errors: @shop_category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      format.html do
        if @shop_category.save
          render :show
        else
          render :new
        end
      end
    end
  end

  def show
    @shop_category = @shop.shop_category
    @children = @shop_category.children.page(params[:page]).per(params[:per])
    @root = @shop_category
  end

  def new_by_child
    @root = @shop.shop_category
    @parent = ShopCategory.find(params[:child_id])
    @shop_category = ShopCategory.new

    render :new
  end

  def edit

  end

  def show_by_child
    @children = @shop_category.children.page(params[:page]).per(params[:per])

    render :show
  end

  def update
    @root = @shop.shop_category
    @shop_category = ShopCategory.find(params[:child_id])
  end

  def update_category
    @shop_category.update shop_category_params
    render :edit
  end

  def update_by_child
    @shop_category.update shop_category_params
    render :show, formats: [ :json ]
  end

  def destroy
    @root = @shop.shop_category
  end

  def destroy_by_child
    @shop_category.destroy
    render :destroy, formats: [:js]
  end

  def upload_image_by_child
    uploader = ImageUploader.new(ShopCategory.new, :image)
    uploader.store! params[:file]

    render json: { success: true, url: uploader.url(:cover), filename: uploader.filename }
  end

  def upload_image
    @shop_category.image = params[:file]
    @shop_category.save
    render json: { success: true, url: @shop_category.image.url(:cover) }
  end

  private

  def shop_category_params
    params.require(:shop_category).permit(:title)
  end

  def is_descendant_of_category
    @root = @shop.shop_category
    @shop_category = ShopCategory.find(params[:child_id])
    raise ActionController::RoutingError.new('Not Found') unless @shop_category.is_or_is_descendant_of?(@root)
  end

  def set_paginating
    params[:per] ||= 11
  end
end
