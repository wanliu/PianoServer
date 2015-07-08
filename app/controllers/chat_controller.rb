class ChatController < ApplicationController
  include ConcernParentResource
  respond_to :json

  json_options user: :simple
  set_parent_param :promotion_id

  def create
    
  end

  private 

  def target_user
    @room.owner == current_user ? @room.target : @room.owner
  end
end
