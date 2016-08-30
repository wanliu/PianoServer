class TempBirthdayPartiesController < ApplicationController
  before_action :set_temp_birthday_party, only: [:show, :update, :destroy]

  # GET /temp_birthday_parties
  # GET /temp_birthday_parties.json
  def index
    @temp_birthday_parties = TempBirthdayParty.all

    render json: @temp_birthday_parties
  end

  # GET /temp_birthday_parties/1
  # GET /temp_birthday_parties/1.json
  def show
    render json: @temp_birthday_party
  end

  # POST /temp_birthday_parties
  # POST /temp_birthday_parties.json
  def create
    @temp_birthday_party = TempBirthdayParty.new(temp_birthday_party_params)

    if @temp_birthday_party.save
      render json: @temp_birthday_party, status: :created, location: @temp_birthday_party
    else
      render json: @temp_birthday_party.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /temp_birthday_parties/1
  # PATCH/PUT /temp_birthday_parties/1.json
  def update
    @temp_birthday_party = TempBirthdayParty.find(params[:id])

    if @temp_birthday_party.update(temp_birthday_party_params)
      head :no_content
    else
      render json: @temp_birthday_party.errors, status: :unprocessable_entity
    end
  end

  # DELETE /temp_birthday_parties/1
  # DELETE /temp_birthday_parties/1.json
  def destroy
    @temp_birthday_party.destroy

    head :no_content
  end

  private

    def set_temp_birthday_party
      @temp_birthday_party = TempBirthdayParty.find(params[:id])
    end

    def temp_birthday_party_params
      params.require(:temp_birthday_party).permit(:cake_id, :quantity, :birth_day, :delivery_time, :user_id, :sales_man_id, :message, :delivery_address, :birthday_person, :person_avatar)
    end
end
