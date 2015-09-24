class UnitsController < ApplicationController
  before_filter :set_unit, only: [:show]

  def index
    @units = if params[:q].present?
      Unit.where("name LIKE ? OR name LIKE ?", "%#{params[:q]}%")
    else
      Unit.page(params[:page]).per(params[:per])
    end
  end

  def show
  end

  protected
    def set_unit
      @unit = Unit.find(params[:id])
    end
end
