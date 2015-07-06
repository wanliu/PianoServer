class Api::MessagesController < Api::BaseController
  include ConcernParentResource
  # include AnalyaticsMentions

  set_parent_param :business_id, class_name: 'Business::Base'

  def index
    @messags = @parent.messages
    # render json: @messages
  end

  def create
    @room = @parent.rooms.find(params[:room_id])
    @message = @room.messages.create(text: params[:text], from_id: current_user.id)
    render :show, formats: [:json]
  end
end
