# require_relative '../../serializers/product_serializer'

class Api::SuggestionController < Api::BaseController
  skip_before_action :authenticate_user!, only: [:search]

  def index
    @suggestions = Product.suggest(params[:suggest]).results
    
    render action: :index, formats: [:json]
    # render json: @suggestions
    # render json: ActiveModel::ArraySerializer.new(@suggestions, each_serializer: ProductSerializer)
  end

  def search
    @suggestions = Suggestion.item_suggest(params[:q]).page(1).per(10)
    render json: @suggestions
  end
end
