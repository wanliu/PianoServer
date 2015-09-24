class CategoriesController < ApplicationController
  def index
    @categories = if params[:category_id].present?
      Category.find(params[:category_id]).children
    else
      Category.first.children
    end

    render json: @categories.as_json(methods: [:is_leaf])
  end
end