class TempBirthdayPartiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_temp_birthday_party, only: [:active]

  def active
    if @temp_birthday_party.generate_order_and_birthday_party(current_user)
      # render "success"
      redirect_to ApplicationController.helpers.birthday_party_path(@temp_birthday_party.party)
    else
      render "failed", status: :unproccessable_entity
    end
  end

  private

  def set_temp_birthday_party
    @temp_birthday_party = TempBirthdayParty.find_by(active_token: params[:token])

    if @temp_birthday_party.blank?
      render "not_found"
    end
  end
end