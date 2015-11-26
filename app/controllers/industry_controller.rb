class IndustryController < ApplicationController
  before_action :authenticate_region!
  before_action :set_industry

  def show
    pp @region
    @regions = get_regions(@region)
    render :show, with: @industry
  end

  def brands
    @category = Category.find(params[:category_id])
    pp @industry
    # @region = Category.find(params[:region_id])
    @brands = Brand.with_category(params[:category_id])
    @brands_group = @brands.group_by { |brand| Pinyin.t(brand.title, splitter: '')[0].upcase }.sort {|a,b| a[0]<=>b[0]}
  end

  def list
    @category = Category.find(params[:category_id])
    @brand = Brand.find(params[:brand_id])
    # @region =
    @shops = Shop
      .joins(:items)
      .where("items.category_id in (?)", [ @category.id, *@category.descendants ])
      .where("items.brand_id in (?)", [ @brand.id ])
      .where("shops.industry_id = ?", @industry.id)
      .where("shops.region_id = ?", @region.city_id)
      .group("shops.id")
  end

  private

  def set_industry
    @industry = Industry.find_by(name: params[:id])
  end

  def get_regions(region)
    @regions = (region && region.ancestors.joins(:status).where("regions.name != ? and statuses.state = 'open'", "China")) || []
  end
end
