class Admins::BirthdayPartiesController < Admins::BaseController
  before_action :set_birthday_party, only: [:show, :edit, :update, :destroy, :undo_delete]

  # GET /birthday_parties
  # GET /birthday_parties.json
  def index
    @birthday_parties = BirthdayParty.includes(cake: :item).order(birth_day: :desc)
      .page(params[:page])
      .per(params[:per])
  end

  # GET /birthday_parties/1
  # GET /birthday_parties/1.json
  def show
    # render json: @birthday_party
  end

  # DELETE /birthday_parties/1
  # DELETE /birthday_parties/1.json
  def destroy
    @birthday_party.destroy

    respond_to do |format|
      format.js
      format.html { head :no_content }
      format.json { head :no_content }
    end
  end

  def undo_delete
    @birthday_party.restore

    respond_to do |format|
      format.js
      format.html { head :no_content }
      format.json { head :no_content }
    end
  end

  private

    def set_birthday_party
      @birthday_party = BirthdayParty.with_deleted.find(params[:id])
    end

    def birthday_party_params
      params.require(:birthday_party).permit(:item_id, :hearts_limit)
    end

    def birthday_party_update_params
      params.require(:birthday_party).permit(:hearts_limit)
    end
end
