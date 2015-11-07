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


  private

  def set_brand
    @brand = Brand.find(params[:id])
  end
end
