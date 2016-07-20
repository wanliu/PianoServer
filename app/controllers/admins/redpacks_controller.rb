class Admins::RedpacksController < Admins::BaseController
  before_action :set_redpack, only: [:show, :update, :send_redpack, :query]

  def index
    @redpacks = Redpack.includes(birthday_party: :user).order(id: :desc).page(params[:page]).per(params[:per])
  end

  def show
  end

  def update
  end

  def send_redpack
    response = @redpack.send_redpack
    if response.success?
      @redpack.update_columns(status: Redpack.statuses["sent"])
    else
      @redpack.update_columns(status: Redpack.statuses["failed"], error_message: response.error_message)
    end

    render "query"
  end

  def query
    response = @redpack.query_redpack
    if response.success?
      @redpack.update_columns(status: Redpack.statuses[response.status])
    else
      status = response.status || "unknown"
      @redpack.update_columns(status: Redpack.statuses[status], error_message: response.fail_reason)
    end
  end

  private

  def set_redpack
    @redpack = Redpack.find(params[:id])
  end
end
