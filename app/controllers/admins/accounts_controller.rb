
class Admins::AccountsController < Admins::BaseController
  before_action :set_admins_account, only: [:show, :update, :destroy]

  class AccountImportError < StandardError

  end
  respond_to :js
  # GET /admins/accounts
  # GET /admins/accounts.json
  def index
    @accounts = if params[:q]
                  User.search_for(params[:q]).page(params[:page])
                else
                  User.page params[:page]
                end
  end

  def search_wanliu_user

    @wanliu_users = WanliuUser.find(:all, params: {q: params[:q] })
    if request.xhr?
      render partial: "search_wanliu_user", :layout => nil
    else
      render "_search_wanliu_user"
    end
  end

  def import
    url = "/api/v1/users/#{params[:wanliu_user_id]}/pry.json"
    @remote_user = WanliuUser.find(:one, from: url)
    if User.can_import?(params[:wanliu_user_id])

      @import_user = User.find_or_initialize_by(id: @remote_user.id)
      @import_user.update(user_sync_options(@remote_user))
      unless @remote_user.shop_id.blank?
        @remote_shop = WanliuShop.find(@remote_user.shop_id)
        @import_shop = Shop.find_or_initialize_by(id: @remote_shop.id)
        @import_shop.update(shop_sync_options(@remote_shop))
      end
    else
      raise AccountImportError.new("can't import this user")
    end

    render :import, :handlers => [:erb], :formats => [:js]
  end

  # GET /admins/accounts/1
  # GET /admins/accounts/1.json
  def show
    render json: @admins_account
  end

  # POST /admins/accounts
  # POST /admins/accounts.json
  def create
    @admins_account = Admins::Account.new(admins_account_params)

    if @admins_account.save
      render json: @admins_account, status: :created, location: @admins_account
    else
      render json: @admins_account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admins/accounts/1
  # PATCH/PUT /admins/accounts/1.json
  def update
    @admins_account = Admins::Account.find(params[:id])

    if @admins_account.update(admins_account_params)
      head :no_content
    else
      render json: @admins_account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /admins/accounts/1
  # DELETE /admins/accounts/1.json
  def destroy
    @admins_account.destroy

    head :no_content
  end

  private

  def set_admins_account
    @admins_account = Admins::Account.find(params[:id])
  end

  def admins_account_params
    params[:admins_account]
  end

  def user_sync_options(user)
    {
      id: user.id,
      username: user.login,
      email: user.email,
      mobile: user.telephone,
      nickname: user.realname,
      encrypted_password: user.encrypted_password,
      provider: 'import'
    }
  end

  def shop_sync_options(shop)
    {
      id: shop.id,
      name: shop.name,
      status: shop.status,
      phone: shop.phone,
      owner_id: shop.owner_id,
      industry_id: shop.industry_id,
      license_no: shop.license_no,
      website: shop.website,
      image: {
        avatar_url: shop.image.src
      },
      provider: 'import'
    }
  end
end
