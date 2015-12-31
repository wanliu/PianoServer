require 'grab_machine'

GrabMachine.setup(user_method: :pmo_current_user)

class Api::Promotions::OneMoneyController < Api::BaseController
  include FastUsers
  skip_before_action :authenticate_user!, only: [:show, :item]
  skip_before_action :authenticate_user!, only: [:signup] unless Rails.env.production?
  before_action :set_one_money #, except: [:, :update, :status, :item]

  def show
    hash = @one_money.to_hash
    hash[:items] = @one_money.items.map {|item| {id: item.id, title: item.title, status: item.status }}
    render json: hash
  end

  def item
    # @one_money = OneMoney[params[:id].to_i]
    @item = PmoItem[params[:item_id].to_i]
    hash = @item.to_hash
    if @item.status == "started"
      executies = @item.winners.find(user_id: current_user.user_id).count
      hash[:executies] = executies
    end

    render json: hash
  end

  def items
    hash = @one_money.attributes
    @items = @one_money.items
    render json: @items
  end

  def signup
    status = @one_money.signups.add(pmo_current_user)
    @one_money.save
    render json: {user_id: pmo_current_user.id, status: status > 0 ? "success" : "always" }
  end

  def status
    hash = @one_money.attributes
    hash[:signup_count] = @one_money.signups.count
    hash[:participant_count] =  @one_money.participants.count
    hash[:winner_count] =  @one_money.winners.count
    hash[:item_count] = @one_money.items.count

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

    if params[:stat].present?
      hash[:items] = @one_money.items.map do |item|
        item_hash = item.attributes
        item_hash[:participant_count] = item.participants.count
        item_hash[:winner_count] = item.winners.count
        item_hash[:total_amount] = item.total_amount
        item_hash[:completes] = item.completes
        # items.status
        item_hash
      end
    end

    render json: hash
  end

  def grab
    @item = PmoItem[params[:item_id].to_i]
    GrabMachine.run self, @one_money, @item do |context|
      # @one_money.participants.add(pmo_current_user)
      id = @item.winners.add(pmo_current_user)
      @one_money.winners.add(pmo_current_user)
      @one_money.save
      render json: {
        winner: id,
        user_id: pmo_current_user.id,
        item: item_id,
        one_money: params[:id],
        status: "success"
      }
    end
    result = {} , code = 200
    item_id = params[:item_id].to_i
    @item = @one_money.items[item_id]

    # if @item.present?
    #   if @item.status == "started"
    #
    #   @item.grabs.find(user_id: pmo_current_user.id, )
    #   if is_winner?(@item, pmo_current_user)
    #     result, code = {
    #       error: "you always winner this OneMoney %d" % [params[:id]],
    #       status: "always"
    #     }, 201
    #   elsif @item.completes + @item.quantity > @item.total_amount # full
    #     result, code = {
    #       error: "Grap this OneMoney dont have inventory",
    #       status: "insufficient"
    #     }, 500
    #
    #     @one_money.participants.add(pmo_current_user)
    #     @one_money.save
    #   else
    #     if @item.can?(:grab, pmo_current_user)
    #
    #       # @one_money.participants.add(pmo_current_user)
    #       id = @item.winners.add(pmo_current_user)
    #       @one_money.winners.add(pmo_current_user)
    #       @one_money.save
    #       result, code = {
    #         winner: id,
    #         user_id: pmo_current_user.id,
    #         item: item_id,
    #         one_money: params[:id],
    #         status: "success"
    #       }, 200
    #     else
    #       result, code = {
    #         error: "you cant do %s action in this item" % [:grab ],
    #         status: "no_action"
    #       }, 400
    #     end
    #   end
    # else
    #   result, code = {
    #     error: "can't found item id: %d in OneMoney[%d]" % [item_id, params[:id]]
    #   }, 404
    # end

    # render json: result, status: code
  end


  def grab_conditions()
    [
      :grab_condition_status?,
      proc { |item| }
    ]
  end

  private

  def set_one_money
    @one_money = OneMoney[params[:id].to_i]
  end

  def pmo_current_user
    @pmo_current_user ||= PmoUser.find(user_id: current_user[:id]).first

    unless @pmo_current_user
      @pmo_current_user = PmoUser.create({
        avatar_url: current_user[:image][:url],
        title: current_user[:nickname],
        username: current_user[:username],
        user_id: current_user[:id]
      })
    end
    @pmo_current_user
  end

end
