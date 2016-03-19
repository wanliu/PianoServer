class Api::EvaluationsController < Api::BaseController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  include EvaluationsConcern
end
