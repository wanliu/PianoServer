class Api::EvaluationsController < Api::BaseController
  skip_before_action :authenticate_user!, only: [ :index, :show, :specified, :aggregate ]

  include EvaluationsConcern

  def specified
    @evaluations = Evaluation.where(evaluationable_type: params[:evaluationable_type], evaluationable_id: params[:evaluationable_id])

    @evaluations =
      case params[:type]
      when nil, "ALL"
        @evaluations
      when "GOOD"
        @evaluations.where("(CAST(items ->> 'good' as integer) + CAST(items ->> 'delivery' AS integer) + CAST(items ->>  'customer_service' AS integer)) > 12")
      when "MEDIUM"
        @evaluations.where("(CAST(items ->> 'good' as integer) + CAST(items ->> 'delivery' AS integer) + CAST(items ->>  'customer_service' AS integer)) BETWEEN 9 AND 12")
      when "BAD"
        @evaluations.where("(CAST(items ->> 'good' as integer) + CAST(items ->> 'delivery' AS integer) + CAST(items ->>  'customer_service' AS integer)) < 9")
      when "IMAGES"
        @evaluations
      end

    @total = @evaluations.count
    @evaluations = @evaluations.page(params[:page])
      .per(params[:per])

    render :index
  end

  def aggregate
    result = Evaluation
      .where(evaluationable_type: params[:evaluationable_type], evaluationable_id: params[:evaluationable_id])
      .select("CASE WHEN CAST(items ->> 'good' as integer) + CAST(items ->> 'delivery' AS integer) + CAST(items ->>  'customer_service' AS integer) > 12 THEN 'GOOD' WHEN CAST(items ->> 'good' as integer) + CAST(items ->> 'delivery' AS integer) + CAST(items ->>  'customer_service' AS integer) > 9 THEN 'MEDIUM' ELSE 'BAD' END AS score_label, COUNT(*) AS count")
      .group("score_label")

    hash = result.to_a.map { |i| [i.score_label, i.count] }.to_h

    render json: hash
  end
end
