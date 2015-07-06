class Api::RoomsController < Api::BaseController
  include ConcernParentResource
  respond_to :json

  json_options user: :simple
  set_parent_param :business_id, class_name: 'Business::Base'

  def index
    @rooms = @parent.rooms
    # render json: @rooms, except: []
  end

  def create
  end

  def negotiate_with
    @target_user = User.find(params[:user_id])
    @room = @parent.rooms.where(target_id: params[:user_id])
      .first_or_create(negotiation_options(@target_user, @parent))

    # @room
   render :show, formats: [:json]
  end

  def accepting
    @room = Room.find(params[:id])

    handshank = Accepting::HandShank.new(@room, :acceptings)
    handshank.accepting(current_user.id)
    if handshank.is_single?
      MessageSystem.push(@room.id, :system, target_user, "#{current_user.nickname} 向你提出订单申请")
    elsif handshank.is_double? 
      MessageSystem.push(@room.id, :system, current_user, "恭喜你已经同意生成订单，你可以在5分钟这内撤销此订单 >> url")
      MessageSystem.push(@room.id, :system, target_user, "恭喜对方接受申请")

    else
    end

    render :show, formats: [:json]
  end

  private 

  def target_user
    @room.owner == current_user ? @room.target : @room.owner
  end

  def negotiation_options(target_user, business, options = {})
    {
      owner_id: current_user.id,
      name: "针对 “#{business.title}” #{current_user.nickname} 与 #{target_user.nickname} 的交易谈判"
    }.merge(options)
  end
end
