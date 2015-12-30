class Api::Promotions::OneMoneyController < Api::BaseController
  include FastUsers
  skip_before_action :authenticate_user!, only: [:show, :item, :signup]
  before_action :set_one_money #, except: [:, :update, :status, :item]

  def show
    render json: @one_money.attributes
  end

  def status
  end

  def update
  end

  def item
    # @one_money = OneMoney[params[:id].to_i]
    @item = PmoItem[params[:item_id].to_i]
    render json: @item.attributes
  end

  def signup
    @one_money.signups.add(pmo_current_user)
    @one_money.save
    render json: {user_id: pmo_current_user.id }
  end

  private

  def set_one_money
    @one_money = OneMoney[params[:id].to_i]
  end

  def pmo_current_user
    user = PmoUser.find(user_id: current_user[:id]).first

    unless user
      user = PmoUser.create({
        # id: current_user[:id],
        avatar_url: current_user[:image][:url],
        title: current_user[:nickname],
        username: current_user[:username],
        user_id: current_user[:id]
        # user_type: "consumer"
      })
    end
    user
  end
end
