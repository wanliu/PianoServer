require 'grab_machine'

GrabMachine.setup(user_method: :pmo_current_user)

class Api::Promotions::OneMoneyController < Api::BaseController
  include FastUsers
  skip_before_action :authenticate_user!, only: [:show, :item, :items, :status]
  skip_before_action :authenticate_user!, only: [:signup] unless Rails.env.production?
  before_action :set_one_money #, except: [:, :update, :status, :item]

  def show
    hash = @one_money.to_hash
    hash[:items] = @one_money.items.map {|item| {id: item.id, title: item.title, status: item.status }}
    render json: hash
  end

  def item
    @item = PmoItem[params[:item_id].to_i]

    now = @item.now.to_f * 1000
    GrabMachine.run self, @one_money, @item do |status, context|
      # @one_money.participants.add(pmo_current_user)
      if status == "success"
        hash = @item.to_hash
        if params[:u].present?
          hash[:td] = now - params[:u].to_i
        end

        # hash[:item_status] = status

        render json: hash
      else
        hash = @item.to_hash
        if params[:u].present?
          hash[:td] = now - params[:u].to_i
        end

        hash[:item_status] = status
        render json: hash
      end
    end
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
    now = @one_money.now.to_f * 1000
    if params[:u].present?
      hash[:td] = now - params[:u].to_i
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
    GrabMachine.run self, @one_money, @item do |status, context|
      if status == "success"
        id = @one_money.winners.add(pmo_current_user)
        id = @item.winners.add(pmo_current_user)
        @one_money.save
        @item.save
        @grab = PmoGrab.from(@item, @one_money, pmo_current_user)
        @grab.save

        # pmo_current_user.grabs.add(@grab)
        # pmo_current_user.save


        render json: {
          winner: id,
          user_id: pmo_current_user.user_id,
          item: params[:item_id],
          one_money: params[:id],
          callback_url: @grab.callback_url,
          time_out: @grab.time_out.minutes.seconds,
          status: "success"
        }
      else
        @one_money.participants.add(pmo_current_user)
        @one_money.save
        render json: context.result, status: context.code
      end
    end
  end

  def callback
    @item = PmoItem[params[:item_id].to_i]
    GrabMachine.run self, @one_money, @item do |status, context|
      case status
      when "always", "no-executies"
        grabs = PmoGrab.find(pmo_item_id: @item.id, one_money: @one_money.id, user_id: pmo_current_user.user_id)
        grab = grabs.reverse_each { |e| break e;  }
        hash = { status: status,
                 grab_id: grab.id,
                 callback_url: grab.callback_url,
               }
        hash[:timeout] = [ grab.timeout_at - grab.now, 0].max if grab.timeout_at.present?

        render json: hash
      else
        render json: { status: status }
      end
    end
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
