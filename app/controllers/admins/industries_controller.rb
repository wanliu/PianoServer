class Admins::IndustriesController < Admins::BaseController
  before_action :get_industry, only: [:edit, :update, :show]
  def new
    @industry = Industry.new
  end

  def index
    @industries = Industry.all
  end

  def create
    @industry = Industry.create industry_params
    redirect_to edit_admins_industry_path(@industry)
  end

  def edit
    @categories = category_root.try(:children) || []
    # demo code, remove after impl
    @properties = Property.all
  end

  def update
    @industry.update_attributes industry_params
    redirect_to edit_admins_industry_path(@industry)
  end

  def sync_es_brands
    # EsBrandsSyncJob.perform_later 'overwrite'
    EsBrandsSync.sync 'overwrite'

    render json: {}, status: :ok
  end

  def destroy

  end

  def sync_es_categories
    # EsCategoriesSyncJob.perform_later 'overwrite'
    EsCategoriesSync.sync 'overwrite'

    render json: {}, status: :ok
  end

  private

  def industry_params
    params.require(:industry).permit(:name, :title, :description)
  end

  def get_industry
    @industry = Industry.find(params[:id])
  end

  def category_root
    Category.roots[0]
  end
end
