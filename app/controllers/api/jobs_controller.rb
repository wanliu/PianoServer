require 'sidekiq'
require 'sidekiq-status'
class Api::JobsController < ApplicationController
  include ActionController::Live

  def show
    status = Sidekiq::Status::status(params[:id])
    data = Sidekiq::Status::get_all params[:id]
    render json: {
      job_id: params[:id],
      status: status,
      data: data
    }
  end

  def stream
    response.headers['Content-Type'] = 'text/event-stream'

    100.times {
      status = Sidekiq::Status::status(params[:id])
      break if [:completem, :failed, :interrupted].include? status
      response.stream.write("data: %s\n\n" % [status])
      sleep 1
    }
  ensure
    response.stream.write("data: %s\n\n" % [status])
    response.stream.close
  end
end
