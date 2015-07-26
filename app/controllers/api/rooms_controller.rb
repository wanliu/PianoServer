class Api::RoomsController < Api::BaseController
  include ConcernParentResource
  respond_to :json

  json_options user: :simple
  set_parent_param :business_id, class_name: 'Business::Base'

  # def index
  #   @rooms = @parent.rooms
  #   # render json: @rooms, except: []
  # end


end
