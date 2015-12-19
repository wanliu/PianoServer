class Shops::Admin::PurchaseOrdersController < Shops::Admin::BaseController
  # before_action :authenticate_user!
  before_action :set_order, only: [:show, :destroy, :update]
  before_action :check_for_mobile, only: [:index, :history, :show, :confirmation, :buy_now_confirm]

  include CommonOrdersController
end