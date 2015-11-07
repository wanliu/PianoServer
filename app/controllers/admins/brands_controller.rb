class Admins::BrandsController < Admins::BaseController
  before_action :set_brand,  only: [ :show ]

  def index
    @brands =
      (if params[:q].present?
        Brand.search(params[:q]).records
      else
        Brand
      end).page(params[:page]).per(100)

    respond_to do |format|
      format.html { render :index }
      format.json { render :index }
    end
  end

  def new
    @brand = Brand.new
  end

  def create
    @brand = Brand.create(brand_params())
    redirect_to admins_brands_path
  end

  def show
    @products = Product.search(query: {
      match: {
        brand_id: @brand.id
      }
    })

    categories_ids = @products.map(&:category_id).uniq
    @categories = Category.where("id in (?)", categories_ids)
    @industries = []
  end

  def upload
    uploader =
      if params[:id].blank?
        uploader = ItemImageUploader.new(Brand.new, :image)
        uploader.store! params[:file]
        uploader
      else
        @brand = Brand.find(params[:id])
        @brand.image = params[:file]
        @brand.save
        @brand.image
      end
    # TODO img :brand
    render json: { success: true, url: uploader.url(:cover)  , filename: uploader.filename }
  end

  private

  def set_brand
    @brand = Brand.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name, :chinese_name, :description, :image)
  end
end
