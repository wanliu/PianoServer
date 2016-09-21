class Admins::CardsController < Admins::BaseController
  before_action :set_card, only: [:show, :update, :destroy]

  # GET /cards
  # GET /cards.json
  def index
    @cards = Card.order(id: :desc).page(params[:page]).per(params[:per])
    @card  = Card.new(available_range: '礼品购')
    # render json: @cards
  end

  # GET /cards/1
  # GET /cards/1.json
  def show
    render json: @card
  end

  # POST /cards
  # POST /cards.json
  def create
    @card = Card.new(card_params)

    respond_to do |format|
      if @card.save
        format.js
        format.html
        format.json { render json: @card, status: :created }
      else
        format.js
        format.html
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cards/1
  # PATCH/PUT /cards/1.json
  def update
    @card = Card.find(params[:id])

    respond_to do |format|
      if @card.update(card_update_params)
        format.js
        format.html { head :no_content }
        format.json { render json: {} }
      else
        format.js
        format.json { render json: @card.errors, status: :unprocessable_entity }
        format.html { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cards/1
  # DELETE /cards/1.json
  def destroy
    @card.destroy

    respond_to do |format|
      format.js
      format.html { head :no_content }
      format.json { head :no_content }
    end
  end

  private

    def set_card
      @card = Card.find(params[:id])
    end

    def card_params
      params.require(:card).permit(:available_range, :wx_card_id, :title)
    end

    def card_update_params
      params.require(:card).permit(:available_range, :title)
    end
end
