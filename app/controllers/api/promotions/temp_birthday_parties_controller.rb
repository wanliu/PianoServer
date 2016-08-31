class Api::Promotions::TempBirthdayPartiesController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_current_sales_man, only: [:create]
  before_action :set_temp_birthday_party, only: [:show, :update, :destroy]

  # GET /temp_birthday_parties
  # GET /temp_birthday_parties.json
  # def index
  #   @temp_birthday_parties = TempBirthdayParty.all

  #   render json: @temp_birthday_parties
  # end

  # GET /temp_birthday_parties/1
  # GET /temp_birthday_parties/1.json
  # def show
  #   render json: @temp_birthday_party
  # end

  # POST /temp_birthday_parties
  # POST /temp_birthday_parties.json
  def create
    @temp_birthday_party = @sales_man.temp_birthday_parties.build(temp_birthday_party_params)

    @temp_birthday_party.quantity ||= 1

    if @temp_birthday_party.save
      render json: @temp_birthday_party.as_json(except: [:active_token]), status: :created
    else
      render json: @temp_birthday_party.errors, status: :unprocessable_entity
    end
  end

  def upload_avatar
    uploader = ItemImageUploader.new(BirthdayParty.new, :person_avatar)
    uploader.store! params[:file]

    render json: { success: true, url: uploader.url(:cover)  , filename: uploader.filename }
  end

  def upload_avatar_media_id
    birthday_party = BirthdayParty.new

    birthday_party.avatar_media_id = params[:avatar_media_id] || params[:temp_birthday_party][:avatar_media_id]

    birthday_party = WxAvatarDownloader.download(birthday_party)

    render json: { success: true, url: birthday_party.person_avatar.url(:cover), filename: birthday_party[:person_avatar] }
  end

  # PATCH/PUT /temp_birthday_parties/1
  # PATCH/PUT /temp_birthday_parties/1.json
  # def update
  #   @temp_birthday_party = TempBirthdayParty.find(params[:id])

  #   if @temp_birthday_party.update(temp_birthday_party_params)
  #     head :no_content
  #   else
  #     render json: @temp_birthday_party.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /temp_birthday_parties/1
  # DELETE /temp_birthday_parties/1.json
  # def destroy
  #   @temp_birthday_party.destroy

  #   head :no_content
  # end

  private

    # def set_temp_birthday_party
    #   @temp_birthday_party = TempBirthdayParty.find(params[:id])
    # end

    def temp_birthday_party_params
      params.require(:temp_birthday_party)
        .permit(:cake_id, :quantity, :birth_day, :person_avatar,
                :delivery_time, :message, :delivery_address, 
                :birthday_person, :delivery_region_id, :receiver_phone)
    end

    def set_current_sales_man
      # current_user.sales_men
      cake = Cake.find(params[:temp_birthday_party][:cake_id]) 
      shop_id = cake.shop_id
      @sales_man = SalesMan.find_by(shop_id: shop_id, user_id: current_user.id)

      if @sales_man.blank?
        head 403
      end
    end
end
