class Api::BusinessController < Api::BaseController
  require_relative 'errors/business_exception'
  before_filter :set_business, only: [:add_participant]

  BUSINESS_TYPES = %w(findgoods)

  def create
    if BUSINESS_TYPES.include?(params[:action_name])
      analytics_question
      search_matchers
      create_business

      # render json: @business, exclude_token: true, exclude: [:matchers, :participants]
      # render @business, locals: { findgood: @business }, formats: [:json]
      render :show, formats: [:json]
    else 
      raise Business::InvalidActionError
    end
  end

  def show
    @business = Business::Base.find(params[:id])
    render :show, formats: [:json]

    # render json: @business, exclude_token: true
    # render @business, locals: { findgood: @business }, formats: [:json]
  end

  def add_participant
    user_id = params[:participant_id].presence
    if user_id
      if @business.add_participate(user_id: user_id)
        render json: {}, status: :ok

        participant = User.find(user_id)
        message_payload = {
          business_id: @business.id,
          started_by_id: @business.started_by_id,
          participant_id: user_id,
          participant_login: participant.login,
          participant_avatar: participant.try(:image)
        }.to_json
        ::Live::Producer.send_participant_message(message_payload)
      else
        render json: {errors: @business.errors.full_message}, status: :unprocessable_entity
      end
    else
      render json: {errors: ["nedd participant_id"]}, status: :unprocessable_entity
    end
  end

  protected 

  def analytics_question
    @items = []
    case params[:action_name]
    when 'findgoods'
      @items << {
        iid: params[:id],
        image: params[:image],
        title: params[:name],
        data: {
          price: params[:price]
        }
      }
    else
    end
    # if @items.length
  end

  def search_matchers
    @matchers = User.all - [current_user]
    @participants = []
  end


  def create_business
    action_name = business_params[:action]
    class_name = "Business::#{action_name.classify}" 
   
    klass = Module.const_get class_name
    @business = klass.create(business_params) do |business|
      business.started_by = current_user
      business.started_at = Time.now
    end 
    @business.add_matchers(@matchers.map{|u| {user_id: u.id}})
    @business.add_participants(@participants.map{|u| {user_id: u.id }})
    @business.items.create(@items)

    message_payload = @business.to_json(methods: [:matcher_ids, :started_by_login])
    ::Live::Producer.send_match_message(message_payload)
  end

  private

  def set_business
    @business = Business::Base.find(params[:id])
  end

  def business_params
    new_params = params.underscore_keys!
    new_params[:title] = @items.map {|i| i[:title] }.join(',')  
    new_params[:action] = new_params.delete(:action_name) if new_params.has_key?(:action_name)
    new_params.permit(:title, :action)
  end  
end
