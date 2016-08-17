class Api::Promotions::BirthdayPartiesController < Api::BaseController
  before_action :set_birthday_party, only: [:show, :update, :edit, :destroy, :withdraw]
  before_action :authenticate_user!, only: [:upload_avatar]

  # GET /birthday_parties
  # GET /birthday_parties.json
  def index
    @birthday_parties = current_user.birthday_parties

    render json: @birthday_parties
  end

  def recently
    day_options = {
      seven_days_ago: 7.days.ago.to_date,
      seven_days_later: 7.days.since.to_date
    }

    ids = BirthdayParty.where("birth_day >= :seven_days_ago AND birth_day <= :seven_days_later", day_options)
    .limit(3)
    .pluck(:id)

    @parties = BirthdayParty.where(id: ids).rank
  end

  # GET /birthday_parties/1
  # GET /birthday_parties/1.json
  def show
    @hearts_count = @birthday_party.blesses
      .where("virtual_present_infor @> ?", {name: 'heart'}.to_json)
      .count
    hearts_limit = @birthday_party.hearts_limit
    @progress = 100
    free = @birthday_party.send(:free_hearts_withdrawable)
    charged = @birthday_party.send(:charged_widthdrawable)

    if @hearts_count < hearts_limit
      @progress = ((free + charged) / (hearts_limit + charged) * 100).floor
    end
  end

  def upload_avatar
    @birthday_party = current_user.birthday_parties.find(params[:id])
    if @birthday_party.update(upload_avatar_params)
      render json: {
        success: true,
        url: @birthday_party.person_avatar.url(:cover),
        filename: @birthday_party.person_avatar.filename }
    else
      render json: { errors: @birthday_party.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def update_avatar_media_id
    @birthday_party = current_user.birthday_parties.find(params[:id])

    @birthday_party.update_column('avatar_media_id', params[:avatar_media_id] || params[:birthday_party][:avatar_media_id])

    @birthday_party = WxAvatarDownloader.download(@birthday_party)
    # @birthday_party.download_avatar_media

    render :show
    # else
      # render json: { errors: @birthday_party.errors.full_messages.join(', ') }, status: :unprocessable_entity
    # end
  end

  # POST /birthday_parties
  # POST /birthday_parties.json
  # def create
  #   @birthday_party = BirthdayParty.new(birthday_party_params)

  #   if @birthday_party.save
  #     render json: @birthday_party, status: :created, location: @birthday_party
  #   else
  #     render json: @birthday_party.errors.full_messages.join(', '), status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /birthday_parties/1
  # PATCH/PUT /birthday_parties/1.json
  def update
    @birthday_party = BirthdayParty.find(params[:id])

    if @birthday_party.update(birethday_party_update_params)
      render json: {}
    else
      render json: { errors: @birthday_party.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # DELETE /birthday_parties/1
  # DELETE /birthday_parties/1.json
  # def destroy
  #   @birthday_party.destroy

  #   head :no_content
  # end

  def rank
    @parties = BirthdayParty.rank
      .page(params[:page])
      .per(params[:per])

    render :rank
  end

  private

    def set_birthday_party
      @birthday_party = BirthdayParty.find(params[:id])
    end

    def birethday_party_update_params
      params.require(:birthday_party).permit(:message)
    end

    def birthday_party_params
      params.require(:birthday_party).permit(:cake_id, :user_id, :hearts_limit, :birth_day, :birthday_person, :person_avatar)
    end

    def upload_avatar_params
      params.require(:birthday_party).permit(:person_avatar)
    end
end
