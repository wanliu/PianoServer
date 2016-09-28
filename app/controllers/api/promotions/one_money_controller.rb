require 'grab_machine'
require 'encryptor'

GrabMachine.setup(user_method: :pmo_current_user)


class Api::Promotions::OneMoneyController < Api::BaseController
  class InvalidSeedOwner < RuntimeError; end

  include FastUsers
  skip_before_action :authenticate_user!, only: [:show, :item, :items, :status, :item_status, :retrieve_seed, :seed, :signup_count, :items_with_gifts]
  skip_before_action :authenticate_user!, only: [:signup, :user_seeds] unless Rails.env.production?
  skip_before_action :authenticate_user!, only: [:signup, :grab, :callback] if ENV['TEST_PERFORMANCE']

  before_action :set_one_money #, except: [:, :update, :status, :item]
  before_action :from_or_got_seed, only: [:item, :grab, :callback]
  before_action :from_seed, only: [:signup]

  rescue_from InvalidSeedOwner, with: :invalid_seed_owner

  def show
    hash = @one_money.to_hash
    now = @one_money.now.to_f * 1000

    if params[:u].present?
      hash[:td] = now - params[:u].to_i
    end
    hash[:items] = @one_money.items.map {|item| {id: item.id, title: item.title, status: item.status }}
    render json: hash
  end

  def item
    @item = PmoItem[params[:item_id].to_i]

    now = @item.now.to_f * 1000
    GrabMachine.run self, @one_money, @item, @options do |status, context|
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
    hash = {}
    @items = @one_money.items

    if params[:u].present?
      now = @one_money.now.to_f * 1000
      hash[:td] = now - params[:u].to_i
    end

    hash[:items] = @items

    render json: hash
  end

  def signup
    status = @one_money.signups.add(pmo_current_user)
    @one_money.save
    if @from_seed
      if PmoGrab.find(one_money: @one_money.id, user_id: pmo_current_user.id).count == 0
        if PmoSeed.find(one_money: @one_money.id, owner_id: @from_seed.owner_id).select{ |s| s.given == pmo_current_user }.count == 0
          @from_seed.given = pmo_current_user
          @from_seed.save
        end
      end
    end
    render json: {user_id: pmo_current_user.id, user_user_id: pmo_current_user.user_id, status: status > 0 ? "success" : "always" }
  end

  def signup_count
    count = @one_money.signups.count

    render json: { count: count }
  end

  def retrieve_seed
    @user = User.find(params[:user_id])
    @callback = URI(params[:callback])
    @pmo_user = PmoUser.find(user_id: @user.id).first
    result = {
      status: "success",
      seed: nil,
    }

    if @pmo_user
      @options = {one_money: @one_money.id, owner_id: @pmo_user.id}
      @options.merge!(period: params[:period]) if params[:period]
      to_key = params[:to] == "query" ? :query : :fragment
      @seed = PmoSeed.find(@options).select {|s| s.status == 'pending' }.first
      if @seed
        hash = Hash[URI.decode_www_form(@callback.send(to_key) || '')]
        if to_key == :fragment
          @callback.fragment = '/?'+ URI.encode_www_form(hash.merge(fromSeed: @seed.seed_id))
        else
          @callback.query = URI.encode_www_form(hash.merge(fromSeed: @seed.seed_id))
        end

        result[:callback_url] = @callback.to_s
      end

      result[:seed] = @seed
    end

    redirect_to @callback.to_s
    # render json: result
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
        item_hash[:id] = item.id
        item_hash[:participant_count] = item.participants.count
        item_hash[:winner_count] = item.winners.count
        item_hash[:total_amount] = item.total_amount
        item_hash[:completes] = item.completes

        if params[:used].present?
          used_seeds = item.seeds.select {|s| s.status == "used" }
          item_hash[:seed_count] = used_seeds.count
          item_hash[:own_seed_count] = used_seeds.select{ |s| s.owner_id == pmo_current_user.id }.count
        end

        # items.status
        item_hash
      end
    end

    render json: hash
  end

  def item_status
    @item = PmoItem[params[:item_id].to_i]
    hash = @item.to_hash
    now = @item.now.to_f * 1000

    if params[:u].present?
      hash[:td] = now - params[:u].to_i
    end

    # if params[:signups].present?
    #   s = [params[:signups].to_i, 50].min
    #   hash[:signups] = @one_money.signups.sort(by: :created_at, order: 'desc', limit: [0, s]).map {|u| u.attributes }
    # end

    if params[:participants].present?
      s = [params[:participants].to_i, 50].min
      hash[:participants] = @item.participants.sort(by: :created_at, order: 'desc', limit: [0, s]).map {|u| u.attributes }
    end

    if params[:winners].present?
      s = [params[:winners].to_i, 50].min
      hash[:winners] = @item.winners.sort(by: :created_at, order: 'desc', limit: [0, s]).map {|u| u.attributes }
    end

    hash[:participant_count] = @item.participants.count
    hash[:winner_count] = @item.winners.count

    if params[:used].present?
      used_seeds = @item.seeds.select {|s| s.status == "used" }
      hash[:seed_count] = used_seeds.count
      hash[:own_seed_count] = used_seeds.select { |s| s.owner_id == pmo_current_user.id }.count
    end

    hash[:total_amount] = @item.total_amount
    hash[:completes] = @item.completes

    render json: hash
  end

  def grab
    @item = PmoItem[params[:item_id].to_i]
    GrabMachine.run self, @one_money, @item, @options do |status, context|
      if status == "success"
        id = @one_money.winners.add(pmo_current_user)
        id = @item.winners.add(pmo_current_user)
        @one_money.save
        @item.save
        @grab = PmoGrab.from(@item, @one_money, pmo_current_user)
        @grab.save

        if @item.is_card
          shop_item = Item.find(@grab.shop_item_id)

          @card_order = CardOrder.create({
            title: shop_item.title,
            user_id: @grab.user_id,
            wx_card_id: shop_item.properties.try(:[], PmoItem::CARD_ATTR_NAME).try(:[], "value"),
            price: @grab.price,
            paid: @grab.price <= 0,
            pmo_grab_id: @grab.id,
            item_id: @grab.shop_item_id,
            one_money_id: @grab.one_money
          })
        end

        if @from_seed
          @from_seed.given = pmo_current_user
          @from_seed.save
        end

        if @seed
          @grab.used_seed = @seed.seed_id
          @grab.save
          @seed.used = true
          @seed.save
        end

        Rails.logger.debug "Increment Completes + #{@item.quantity}"
        @item.incr :completes, @item.quantity

        # pmo_current_user.grabs.add(@grab)
        # pmo_current_user.save

        render json: {
          winner: id,
          grab_id: @grab.id,
          user_id: pmo_current_user.id,
          user_user_id: pmo_current_user.user_id,
          item: params[:item_id],
          one_money: params[:id],
          callback_url: @grab.callback_url,
          time_out: @grab.time_out.minutes.seconds,
          status: "success"
        }
      else
        case status
        when "insufficient"
          @item.set_status :suspend
        end

        @one_money.participants.add(pmo_current_user)
        @one_money.save
        @item.participants.add(pmo_current_user)
        @item.save
        Rails.logger.debug "Status: #{status} context:#{context.result}" if ENV['TEST_PERFORMANCE']
        render json: context.result, status: context.code
      end
    end
  end

  def callback
    @item = PmoItem[params[:item_id].to_i]
    GrabMachine.run self, @one_money, @item, @options do |status, context|
      grabs = PmoGrab.find(pmo_item_id: @item.id, one_money: @one_money.id, user_id: pmo_current_user.id)

      hash ={
        status: status
      }
      now = @item.now

      if grabs.count > 0
        hash[:grabs] = grabs.map do |g|
          g.to_hash.except(:shop_id, :callback, :time_out).merge({
            timeout: g.timeout_at.present? ? [ g.timeout_at - now, 0].max : -1,
            callback_url: g.callback_url
          })
        end
      end

      render json: hash
    end
  end

  def ensure
    @grab = PmoGrab[params[:grab_id].to_i]
    hash = JSON.parse encryptor.decrypt(params[:encode_message])
    @grab.status = hash[:state]
    @grab.save
    @grab.cancel_expire(:timeout)
  rescue
    hash = { status: "failed" }
  ensure
    render json: hash
  end

  def user_seeds
    user = User.find(params[:user_id])
    pmo_user = PmoUser.find(user_id: user.id).first || PmoUser.from(user)
    pmo_user.save if pmo_user.new?
    @options = {one_money: @one_money.id, owner_id: pmo_user.id}
    @options.merge!(period: params[:period]) if params[:period]
    @seeds = PmoSeed.find(@options)
    hash ={
      status: "success",
      seeds: @seeds
    }

    render json: hash
  end

  def seed
    @seed = PmoSeed.find(one_money: @one_money.id, seed_id: params[:seed_id]).first
    render json: {
      status: "success",
      seed: @seed
    }
  end

  def items_with_gifts
    items_with_gifts = @one_money.items_with_gifts || ''

    gift_items = if items_with_gifts.length > 0 then items_with_gifts.split(',').map do |id|
      item = Item.find(id)

      since = case params[:since]
      when "month", "m", nil
        1.month.ago
      when "week", "w"
        1.week.ago
      else
        1.month.ago
      end

      count = item.order_items.where("created_at > :since", since: since).count
      current_stock = item.current_stock

      gifts = item.gifts.as_json(methods: [:title, :avatar_url, :inventory, :cover_url, :sid, :public_price])
      json = item.as_json(except: [:income_price, :public_price], methods: [:shop_name, :shop_realname])
      json['avatar_urls'] = [item.avatar_url]
      json['cover_urls'] = [item.cover_url]
      json['gifts'] = gifts
      json['ori_price'] = item.public_price
      json['total_amount'] = current_stock.to_i + count
      json['completes'] = count

      json
    end else
      []
    end

    render json: gift_items
  end

  protected

  def from_seed
    if params[:from_seed]
      @from_seed = PmoSeed.find(seed_id: params[:from_seed]).first
    end
  end

  def from_or_got_seed
    @options = {}

    if params[:from_seed]
      @from_seed = PmoSeed.find(seed_id: params[:from_seed]).first
    end

    if params[:seed]
      @seed = PmoSeed.find(seed_id: params[:seed]).first
      if @seed && @seed.owner_id == pmo_current_user.id
        @options[:seed] = @seed
      else
        raise InvalidSeedOwner.new('Invalid owner_id of seed')
      end
    end
  end

  def invalid_seed_owner(e)
    render json: {
      status: "invalid_seed_owner",
      msg: e.message
    }
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

  def encryptor
    @encryptor ||=  Encryptor.new(Rails.application.secrets[:secret_key_base], "one_money")
  end
end
