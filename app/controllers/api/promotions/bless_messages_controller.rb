class Api::Promotions::BlessMessagesController < Api::BaseController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :check_permission, only: [:destroy]
  before_action :set_bless_message, only: [:destroy]

  # POST /bless_message
  # POST /bless_message.json
  def create
    @bless_message = BlessMessage.create(bless_message_params)
    @bless_message.sender = current_user

    if @bless_message.save
      render json: @bless_message, status: :created
    else
      render json: @bless_message.errors.full_messages.join(', '), status: :unprocessable_entity
    end
  end

  private
    def check_permission
      if sender_id != current_user.id && sender_id != @bless_message.party_owner_id
        head 403
      end
    end

    def set_bless_message
      @bless_message = BlessMessage.find(params[:id])
    end

    def bless_message_params
      params.require(:bless_message).permit(:message, :bless_id)
    end
end
