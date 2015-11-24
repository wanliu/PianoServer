class Admins::RegionsController < Admins::BaseController
  AVALIABLE_STATUS = %w(open close)

  def index
    @root = Region.find_by(name: "China")
    @regions = @root.children.includes(:status)
  end

  def edit
    @region = Region.find(params[:id])
    @regions = @region.children.includes(:status)
  end

  def update

    @region = Region.find(params[:id])
    params = region_params
    state = params.delete(:state)
    pp state
    if state && AVALIABLE_STATUS.include?(state)
      @region.create_status(state: state)
    end

    @region.update_attributes(params)
  end

  private

  def region_params
    params.require(:region).permit(:state, :title)
  end
end
