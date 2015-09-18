class Admins::PromotionsController < Admins::BaseController
	def index
    @title = "最新活动"
    @promotions = Promotion.find(:all, from: :active, params: query_params)
	end

	private

  def query_params
    @query_params = {
      page: params[:page] || 1,
      category_id: params[:category_id],
      inline: params[:inline]
    }
  end
end
