class Api::FavoritesController < Api::BaseController
  before_action :set_favorite, only: [:show, :destroy]

  # GET /favorites
  # GET /favorites.json
  def index
    favoritable_type = params[:type] || params[:favoritable_type]

    @favorites = if favoritable_type.present?
      current_user.favoritables
        .where(favoritable_type: favoritable_type)
    else
      current_user.favoritables
    end

    @total = @favorites.count

    @favorites = @favorites
      .page(params[:page])
      .per(params[:per])

    # render json: {favorites: @favorites, total: @total}
  end

  # GET /favorites/1
  # GET /favorites/1.json
  def show
    render json: @favorite
  end

  def favored
    is_favored = current_user.favoritables
      .exists?(favoritable_type: params[:favoritable_type], favoritable_id: params[:favoritable_id])

    render json: {favored: is_favored}
  end

  # POST /favorites
  # POST /favorites.json
  def create
    @favorite = current_user.favoritables.build(favorite_params)

    if @favorite.save
      render json: @favorite, status: :created
    else
      render json: @favorite.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /favorites/1
  # PATCH/PUT /favorites/1.json
  # def update
  #   if @favorite.update(favorite_params)
  #     head :no_content
  #   else
  #     render json: @favorite.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /favorites/1
  # DELETE /favorites/1.json
  def destroy
    @favorite.destroy

    head :no_content
  end

  private

    def set_favorite
      @favorite = if params[:favoritable_id].present? && params[:favoritable_type].present?
        current_user.favoritables.find_by(favoritable_id: params[:favoritable_id], favoritable_type: params[:favoritable_type])
      else
        current_user.favoritables.find(params[:id])
      end
    end

    def favorite_params
      params.require(:favorite).permit(:favoritable_id, :favoritable_type)
    end
end
