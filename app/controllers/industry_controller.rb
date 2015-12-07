class IndustryController < ApplicationController
  before_action :authenticate_region!
  before_action :set_industry

  helper_method :brands_ids
  # before_action :region_updowns

  def show
    @regions = get_regions(@region)
    @current_region = @region
    region_updowns

  end

  def brands
    @category = Category.find(params[:category_id])
    @current_region = Region.find(params[:region_id])
    # @region = Category.find(params[:region_id])
    @brands = Brand.with_category(params[:category_id])
    @brands_group = @brands.group_by { |brand| Pinyin.t(brand.title, splitter: '')[0].upcase }.sort {|a,b| a[0]<=>b[0]}
  end

  def shops
    @category = Category.find(params[:category_id])
    @current_region = Region.find(params[:region_id] || @region.id)
    # @brand = Brand.find(params[:brand_id])
    @regions = get_regions(@region)

    region_updowns
    # @region =
    @shops = Shop
      .joins(:items)
      .where("items.category_id in (?)", [ @category.id, *@category.descendants ])
      .where("items.brand_id in (?)", brands_ids.map(&:to_i))
      .where("shops.industry_id = ?", @industry.id)
      .where("shops.region_id = ?", @current_region.city_id)
      .group("shops.id")

    @brands_ids = brands_ids
    pp @brands_ids
    @brands = Brand.with_category(params[:category_id])
    @brands_group = @brands.group_by { |brand| Pinyin.t(brand.title, splitter: '')[0].upcase }.sort {|a,b| a[0]<=>b[0]}
  end

  def region
    @current_region = Region.find(params[:region_id])
    @regions = get_regions(@region)
    region_updowns

    render :show, with: @industry
  end

  def categories

  end

  def brands_ids
    params[:brands_ids].present? ? params[:brands_ids]: [params[:brand_id]]
  end

  private

  def set_industry
    @industry = Industry.find_by(name: params[:id])
  end

  def get_regions(region)
    region_self_and_ancestors(region)
  end

  def region_self_and_ancestors(region)
    if region.blank?
      []
    else
      regions = region_ancestors(region)
      regions.push(region)
      regions
    end
  end

  def region_ancestors(region)
    region.ancestors.joins(:status).where("regions.name != ? and statuses.state = 'open'", "China").to_a
  end

  def region_updowns
    index = @regions.index @current_region
    previous = index - 1
    _next = index + 1
    @previous_region = previous >= 0 ? @regions[previous] : nil
    @next_region = _next < @regions.length ? @regions[_next] : nil
  end
end
