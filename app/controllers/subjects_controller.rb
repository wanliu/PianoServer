class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show, :update, :destroy]
  include SubjectsHelper

  def show
    @subject.punch(request)
    @promotions = Promotion.find(:all, from: :active).to_a
    respond_to do |format|
      format.json { render json: @subject }
      format.html { render :index, with: @subject }
    end
  end

  private

    def set_subject
      @subject = Subject.find(params[:id])
    end

    def subject_params
      params[:subject]
    end
end
