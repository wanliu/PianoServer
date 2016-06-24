class Api::Promotions::BirthdayPartiesController < Api::BaseController
  before_action :set_birthday_party, only: [:show, :update, :edit, :destroy]
  before_action :authenticate_user!, only: [:upload_avatar]

  # GET /birthday_parties
  # GET /birthday_parties.json
  def index
    @birthday_parties = current_user.birthday_parties

    render json: @birthday_parties
  end

  # GET /birthday_parties/1
  # GET /birthday_parties/1.json
  def show
    @blesses = @birthday_party.blesses
      .includes(:sender, :virtual_present)
      .order(id: :desc)
      .paid
      .page(params[:page])
      .per(params[:per])
    @blesses_page = @blesses.current_page
    @blesses_total_page = @blesses.total_pages
  end

  def upload_avatar
    @birthday_party = current_user.birthday_parties.find(params[:id])
    if @birthday_party.update(upload_avatar_params)
      render json: {
        success: true, 
        url: @birthday_party.person_avatar.url(:cover), 
        filename: @birthday_party.person_avatar.filename }
    else
      render json: {errors: @birthday_party.errors}, status: :unprocessable_entity
    end
  end

  # POST /birthday_parties
  # POST /birthday_parties.json
  # def create
  #   @birthday_party = BirthdayParty.new(birthday_party_params)

  #   if @birthday_party.save
  #     render json: @birthday_party, status: :created, location: @birthday_party
  #   else
  #     render json: @birthday_party.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /birthday_parties/1
  # PATCH/PUT /birthday_parties/1.json
  # def update
  #   @birthday_party = BirthdayParty.find(params[:id])

  #   if @birthday_party.update(birthday_party_params)
  #     head :no_content
  #   else
  #     render json: @birthday_party.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /birthday_parties/1
  # DELETE /birthday_parties/1.json
  # def destroy
  #   @birthday_party.destroy

  #   head :no_content
  # end

  private

    def set_birthday_party
      @birthday_party = BirthdayParty.find(params[:id])
    end

    def birthday_party_params
      params.require(:birthday_party).permit(:cake_id, :user_id, :hearts_limit, :birth_day, :birthday_person, :person_avatar)
    end

    def upload_avatar_params
      params.require(:birthday_party).permit(:person_avatar)
    end
end