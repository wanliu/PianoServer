class Admins::OneMoneyController < Admins::BaseController

  def index
    @one_moneies = OneMoney.page
  end

  def show
  end

  def edit
    @one_money = OneMoney.new(params[:id])
  end
end
