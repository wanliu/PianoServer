class Admins::OneMoneyController < Admins::BaseController

  def index
    @one_moneies = OneMoney.all
  end

  def new
    @one_money = OneMoney.new
  end
  
  def show
  end

  def edit
    @one_money = OneMoney.new(params[:id])
  end
end
