class EvaluationsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :thumb, :un_thumb]
  before_action :set_evaluation, only: [:show, :update, :destroy, :thumb, :un_thumb]
  skip_before_action :verify_authenticity_token, only: [:create, :thumb, :un_thumb]

  include EvaluationsConcern
end
