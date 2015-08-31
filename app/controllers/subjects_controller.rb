class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show, :update, :destroy]
  include SubjectsHelper
  include ContentManagementService::ContentController

  register_render_template :index, only: [ :show ]

  def show
    @subject.punch(request)
    @promotions = Promotion.find(:all, from: :active).to_a
    respond_to do |format|
      format.json { render json: @subject }
      format.html { subject_render @subject, :index }
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
