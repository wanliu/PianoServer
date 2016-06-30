require "weixin_api"

class BirthdayPartiesController < ApplicationController
  before_action :authenticate_user!, only: :withdraw

  before_action :set_birthday_party, only: :show

  def show
    # @blesses = @birthday_party.blesses
    #   .includes(:sender, :virtual_present)
    #   .order(id: :desc)
    #   .paid

    # render json: @birthday_party
  end

  def withdraw
    @birthday_party = current_user.birthday_parties.find(params[:id])

    wx_query_code = params[:code]
    openid = WeixinApi.code_to_openid(wx_query_code)

    @birthday_party.wx_user_openid = openid
    @birthday_party.request_ip = request.ip

    @withdraw_status = @birthday_party.withdraw
    # if withdraw_status.success?
    #   render json: {}
    # else
    #   render json: { errors: withdraw_status.error_message }, status: :unprocessable_entity
    # end
  end

  private

  def set_birthday_party
    @birthday_party = BirthdayParty.find(params[:id])
  end
end
