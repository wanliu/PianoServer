class Api::ErrorRecordsController < Api::BaseController
  skip_before_action :authenticate_user!

  def index
    records = ErrorRecord.order(id: :desc).page(params[:page]).per(params[:per])

    render json: records
  end

  def create
    record = ErrorRecord.new(error_record_params)
    record.refer = request.referer

    record.save

    render json: {}, status: :created
  end

  private

  def error_record_params
    params.require(:error_record).permit(:name).tap do |white_list|
      if params[:error_record][:infor].present?
        white_list[:infor] = params[:error_record][:infor]
      end
    end
  end
end
