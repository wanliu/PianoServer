class BrandsController < ApplicationController

  def index
    if params[:q].blank?
      @brands = [] # suggestion(current_anonymous_or_user, :brand).map {|brand| {id: brand.id, text: brand.title }}
    else
      @brands = Brand.search(params[:q]).records.map {|brand| {id: brand.id, text: brand.title }}
    end

    render json: {
      results: @brands
    }
  end

  def update
    @brand = Brand.find(params[:id])
    @brand.punch(request)
    render nothing: true
  end
end
