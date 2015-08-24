class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show, :update, :destroy]


  def show
    @subject.punch(request)
    render json: @subject
  end

  private

    def set_subject
      @subject = Subject.find(params[:id])
    end

    def subject_params
      params[:subject]
    end
end
