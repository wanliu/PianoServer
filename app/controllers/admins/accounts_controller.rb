
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
    byebug
    @import_user = User.can_import?(params[:wanliu_user_id])
    if @import_user
      if @import_user.is_a?(User)
        @import_user.update({
          username: remote_user.login,
          email: remote_user.email,
          mobile: remote_user.telephone,
          nickname: remote_user.realname,
          encrypted_password: remote_user.encrypted_password
        })
      else
        @import_user = User.new({
          id: @remote_user.id,
          username: @remote_user.login,
          email: @remote_user.email,
          mobile: @remote_user.telephone,
          nickname: @remote_user.realname,
          encrypted_password: @remote_user.encrypted_password
        })
        @import_user.save(validate: false)
      end
    else
      raise AccountImportError.new("can't import this user")
    end

    # {"id"=>7,
    #  "uid"=>nil,
    #  "business_type"=>nil,
    #  "login"=>"stranger",
    #  "email"=>"email2656@wanliu.corp",
    #  "telephone"=>nil,
    #  "realname"=>"stranger",
    #  "birthday"=>nil,
    #  "gender"=>nil,
    #  "corp"=>nil,
    #  "signature"=>nil,
    #  "description"=>"description7",
    #  "settings"=>nil,
    #  "created_at"=>"2015-07-12T10:03:43.349+08:00",
    #  "updated_at"=>"2015-07-21T10:03:43.349+08:00",
    #  "password_digest"=>nil,
    #  "step"=>nil,
    #  "remember_token"=>"a8490ff94649770382b8481399915287c3f094c8",
    #  "location_id"=>nil,
    #  "address"=>nil,
    #  "recommand_blacklists"=>[],
    #  "encrypted_password"=>
    #   "$2a$10$xYg3n9XExPoSqP79PCAnZ.GNQKoyPStwiRcNskg9vbhCikXww.4OS",
    #  "reset_password_token"=>nil,
    #  "reset_password_sent_at"=>nil,
    #  "remember_created_at"=>nil,
    #  "sign_in_count"=>0,
    #  "current_sign_in_at"=>nil,
    #  "last_sign_in_at"=>nil,
    #  "current_sign_in_ip"=>nil,
    #  "last_sign_in_ip"=>nil,
    #  "confirmation_token"=>nil,
    #  "confirmed_at"=>"2015-07-15T10:03:43.349+08:00",
    #  "confirmation_sent_at"=>nil,
    #  "unconfirmed_email"=>nil,
    #  "authentication_token"=>"WsxEJKouBVbd8wKpyTsE",
    #  "business_circle_id"=>nil,
    #  "industry_id"=>nil},
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
end
