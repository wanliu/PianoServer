class Api::Promotions::OneMoneyController < Api::BaseController
  include FastUsers
  skip_before_action :authenticate_user!, only: [:show, :item, :signup]
  before_action :set_one_money #, except: [:, :update, :status, :item]

  def show
    hash = @one_money.attributes
    hash[:items] = @one_money.items # .map { |item| item.attributes }
    render json: hash
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

  def items
    hash = @one_money.attributes
    @items = @one_money.items.map { |item| item.attributes }
    render json: @items
  end

  def signup
    @one_money.signups.add(pmo_current_user)
    @one_money.save
    render json: {user_id: pmo_current_user.id }
  end

  def status
    hash = @one_money.attributes
    hash[:signup_count] = @one_money.signups.count
    hash[:participant_count] =  @one_money.participants.count
    hash[:winner_count] =  @one_money.winners.count

    if params[:u].present?
      hash[:td] = (Time.now.to_f * 1000) - params[:u].to_i
    end

    if params[:signups].present?
      s = [params[:signups].to_i, 50].min
      hash[:signups] = @one_money.signups.sort(by: :created_at, order: 'desc', limit: [0, s]).map {|u| u.attributes }
    end

    if params[:participants].present?
      s = [params[:participants].to_i, 50].min
      hash[:participants] = @one_money.participants.sort(by: :created_at, order: 'desc', limit: [0, s]).map {|u| u.attributes }
    end

    if params[:winners].present?
      s = [params[:winners].to_i, 50].min
      hash[:winners] = @one_money.winners.sort(by: :created_at, order: 'desc', limit: [0, s]).map {|u| u.attributes }
    end

    render json: hash
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
