# require_relative '../../serializers/product_serializer'

class Api::SuggestionController < Api::BaseController

  def index
    @suggestions = Product.suggest(params[:suggest]).results
    
    render action: :index, formats: [:json]
    # render json: @suggestions
    # render json: ActiveModel::ArraySerializer.new(@suggestions, each_serializer: ProductSerializer)
  end
end
