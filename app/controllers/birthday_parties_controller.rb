require "weixin_api"

class BirthdayPartiesController < ApplicationController
  before_action :authenticate_user!, only: [:withdraw, :index, :blessed]

  before_action :set_birthday_party, only: :show

  def index
    @birthday_parties = current_user.birthday_parties
      .order(id: :desc)
      .page(params[:page])
      .per(params[:per])
  end

  def blessed
    @birthday_parties = BirthdayParty.joins(:blesses)
      .where("blesses.sender_id = :sender_id AND blesses.paid ='t'", sender_id: current_user.id)
      .distinct
      .order(id: :desc)
      .page(params[:page])
      .per(params[:per])
  end

  def show
    # @blesses = @birthday_party.blesses
    #   .includes(:sender, :virtual_present)
    #   .order(id: :desc)
    #   .paid

    # render json: @birthday_party
  end

  def withdraw
    @birthday_party = current_user.birthday_parties.find(params[:id])

    if @birthday_party.order.finish?
      wx_query_code = params[:code]
      openid = WeixinApi.code_to_openid(wx_query_code)

      @birthday_party.wx_user_openid = openid
      @birthday_party.request_ip = request.ip

      @withdraw_status = @birthday_party.withdraw
    else
      @withdraw_status = BirthdayParty::WithdrawStatus.new(false, "订单尚未完成，请在订单完成（收货）后再试！")
    end
  end

  private

  def set_birthday_party
    @birthday_party = BirthdayParty.find(params[:id])
  end
end
