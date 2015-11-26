class IndustryController < ApplicationController
  before_action :authenticate_region!
  before_action :set_industry

  def show
    @regions = get_regions(@region)
    render :show, with: @industry
  end

  def brands
    @category = Category.find(params[:category_id])
    # @region = Category.find(params[:region_id])
    @brands = Brand.with_category(params[:category_id])
    @brands_group = @brands.group_by { |brand| Pinyin.t(brand.title, splitter: '')[0].upcase }.sort {|a,b| a[0]<=>b[0]}
  end

  private

  def set_industry
    @industry = Industry.find_by(name: params[:id])
  end

  def get_regions(region)
    @regions = (region && region.ancestors.joins(:status).where("regions.name != ? and statuses.state = 'open'", "China")) || []
  end
end
