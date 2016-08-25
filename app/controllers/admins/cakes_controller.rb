class Admins::CakesController < Admins::BaseController
  before_action :set_cake, only: [:show, :edit, :update, :destroy, :undo_delete]

  # GET /cakes
  # GET /cakes.json
  def index
    @cakes = Cake.with_deleted.order(deleted_at: :desc, id: :desc).includes(:item)
      .page(params[:page])
      .per(params[:per])

    @cake = Cake.new(hearts_limit: 30)
  end

  def search_items
    search_options = { query: { match: { title: params[:q] } } }
    
    items = Item.search(search_options).records.limit(10)
    render json: items.as_json(methods: [:title, :cover_url, :shop_name])
  end

  def new
    @cake = Cake.new
  end

  # GET /cakes/1
  # GET /cakes/1.json
  def show
    # render json: @cake
  end

  # POST /cakes
  # POST /cakes.json
  def create
    @cake = Cake.new(cake_params)

    respond_to do |format|
      if @cake.save
        format.js
        format.html do
          flash[:notice] = "蛋糕创建成功"
          redirect_to admins_cakes_path
        end
        format.json { render json: @cake, status: :created, location: @cake }
      else
        format.js
        format.html do
          flash[:errors] = @cake.errors.full_messages.join(', ')
          render :edit
        format.json { render json: @cake.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /cakes/1
  # PATCH/PUT /cakes/1.json
  def update
    respond_to do |format|
      if @cake.update(cake_update_params)
        format.js
        format.html { head :no_content }
        format.json { render json: {} }
      else
        format.js
        format.json { render json: @cake.errors, status: :unprocessable_entity }
        format.html { head :no_content }
      end
    end
  end

  # DELETE /cakes/1
  # DELETE /cakes/1.json
  def destroy
    @cake.destroy

    respond_to do |format|
      format.js
      format.html { head :no_content }
      format.json { head :no_content }
    end
  end

  def undo_delete
    @cake.restore

    respond_to do |format|
      format.js
      format.html { head :no_content }
      format.json { head :no_content }
    end
  end

  private

    def set_cake
      @cake = Cake.with_deleted.find(params[:id])
    end

    def cake_params
      params.require(:cake).permit(:item_id, :hearts_limit)
    end

    def cake_update_params
      params.require(:cake).permit(:hearts_limit)
    end
end
