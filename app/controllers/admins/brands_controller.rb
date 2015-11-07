class Admins::BrandsController < Admins::BaseController
  before_action :set_brand,  only: [ :show, :upload ]

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
    @brand.image = params[:file]
    @brand.save
    uploader = @brand.image
    # TODO img :brand
    render json: { success: true, url: uploader.url(:cover)  , filename: uploader.filename }
  end

  private

  def set_brand
    @brand = Brand.find(params[:id])
  end
end
