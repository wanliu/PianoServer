class Shops::Admin::PurchaseOrdersController < Shops::Admin::BaseController
  # before_action :authenticate_user!
  before_action :set_order, only: [:show, :destroy, :update]

  include CommonOrdersController
end