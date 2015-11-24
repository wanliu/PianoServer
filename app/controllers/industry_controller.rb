class IndustryController < ApplicationController
  before_action :authenticate_region!

  def show
    @industry = Industry.find_by(name: params[:id])
    @regions = get_regions(@region)
    render :show, with: @industry
  end

  private

  def get_regions(region)
    @regions = (region && region.ancestors.joins(:status).where("regions.name != ? and statuses.state = 'open'", "China")) || []
  end
end
