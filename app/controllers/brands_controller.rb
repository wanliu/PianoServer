class BrandsController < ApplicationController

  def index
    if params[:q].blank?
      @brands = [] # suggestion(current_anonymous_or_user, :brand).map {|brand| {id: brand.id, text: brand.title }}
    else
      @brands = Brand.search(params[:q]).records.map {|brand| {id: brand.id, text: brand.title }}
    end

    render json: {
      results: @brands.as_json(methods: :title)
    }
  end

  def filter
    if params.has_key?(:category_id)
      @categories = Category.find(params[:category_id]).children
      @brands = Brand.with_category(params[:category_id])
    elsif params.has_key?(:categories_ids)
      categories_ids = params[:categories_ids].split(',')

      @categories = Category.where(id: categories_ids)
      pp categories_ids
      pp category_group = @categories.map {|cate| [cate.id, *cate.descendants.pluck(:id) ] }
      pp ids = category_group.flatten
      @brands = Brand.with_categories(ids)
    end

    render json: {
      brands: @brands.as_json(methods: :title),
      categories: @categories
    }
  end

  def update
    @brand = Brand.find(params[:id])
    @brand.punch(request)
    render nothing: true
  end
end
