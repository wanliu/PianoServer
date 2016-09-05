class Api::Promotions::TempBirthdayPartiesController < Api::BaseController
  before_action :authenticate_user!
  before_action :check_is_sales_man, only: [:create, :update]
  before_action :set_temp_birthday_party, only: [:update, :destroy]
  before_action :set_deleted_temp_birthday_party, only: [:show, :is_actived]

  # GET /temp_birthday_parties
  # GET /temp_birthday_parties.json
  # def index
  #   @temp_birthday_parties = TempBirthdayParty.all

  #   render json: @temp_birthday_parties
  # end

  # GET /temp_birthday_parties/1
  # GET /temp_birthday_parties/1.json
  def show
    @temp_birthday_party.build_order_and_order_item(current_user)
    @is_sales_man = user_signed_in? &&
      (@temp_birthday_party.cake.shop.sales_men.exists?(user_id: current_user.id) ||
        @temp_birthday_party.cake.shop.owner_id == current_user.id)
    render "create"
  end

  def is_actived
    is_actived = @temp_birthday_party.deleted?
    render json: { actived: is_actived }
  end

  # POST /temp_birthday_parties
  # POST /temp_birthday_parties.json
  def create
    @temp_birthday_party = current_user.temp_birthday_parties.build(temp_birthday_party_params)

    @temp_birthday_party.quantity ||= 1

    if @temp_birthday_party.save
      @temp_birthday_party.build_order_and_order_item(current_user)
      @is_sales_man = true
      # render json: @temp_birthday_party.as_json(except: [:active_token]), status: :created
      render "create", status: :created
    else
      render json: @temp_birthday_party.errors, status: :unprocessable_entity
    end
  end

  def update
    if @temp_birthday_party.update(temp_birthday_party_params)
      @temp_birthday_party.build_order_and_order_item(current_user)
      @is_sales_man = true
      render "create"
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

    def set_temp_birthday_party
      @temp_birthday_party = current_user.temp_birthday_parties.find(params[:id])
    end

    def set_deleted_temp_birthday_party
      @temp_birthday_party = current_user.temp_birthday_parties.with_deleted.find(params[:id])
    end

    def temp_birthday_party_params
      params.require(:temp_birthday_party)
        .permit(:cake_id, :quantity, :birth_day, :person_avatar,
                :delivery_time, :message, :delivery_address,
                :birthday_person, :delivery_region_id, :receiver_phone).tap do |white_list|
          white_list[:properties] = params[:temp_birthday_party][:properties] || {}
      end
    end

    def check_is_sales_man
      cake = Cake.find(params[:temp_birthday_party][:cake_id])
      shop = Shop.find(cake.shop_id)
      sales_man = SalesMan.find_by(shop_id: shop.id, user_id: current_user.id)

      if shop.owner_id != current_user.id && sales_man.blank?
        head 403
      end
    end
end
