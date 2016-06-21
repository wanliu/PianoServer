class BirthdayPartiesController < ApplicationController
  before_action :set_birthday_party

  def show
    # @blesses = @birthday_party.blesses
    #   .includes(:sender, :virtual_present)
    #   .order(id: :desc)
    #   .paid

    # render json: @birthday_party
  end

  private

  def set_birthday_party
    @birthday_party = BirthdayParty.find(params[:id])
  end
end