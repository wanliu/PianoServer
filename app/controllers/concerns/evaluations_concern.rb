module EvaluationsConcern
  # GET /evaluations
  # GET /evaluations.json
  def index
    @evaluations = if params[:pmo_item_id].present?
      Evaluation.where(evaluationable_type: 'PmoItem', evaluationable_id: params[:pmo_item_id])
    else
      Evaluation.where(evaluationable_id: params[:evaluationable_id], evaluationable_type: params[:evaluationable_type])
    end

    @total = @evaluations.count
    @evaluations = @evaluations.page(params[:page])
      .per(params[:per])

    # render json: @evaluations
  end

  # GET /evaluations/1
  # GET /evaluations/1.json
  def show
    @thumbers_count = @evaluation.thumbers.count
    @thumbers = @evaluation.thumbers.page(params[:page]).per(params[:per])
  end

  def new
    @evaluation = if params[:grab_id].present?
      grab = PmoGrab[params[:grab_id]]
      pmo_item_id = grab.pmo_item_id
      Evaluation.new(evaluationable_type: 'PmoItem', evaluationable_id: pmo_item_id)
    else
      Evaluation.new
    end
  end

  # POST /evaluations
  # POST /evaluations.json
  def create
    @evaluation = current_user.evaluations.build(evaluation_params)

    if @evaluation.order.evaluated?
      evaluation = @evaluation.order.evaluations.find_by(user_id: current_user.id)
      render json: {errors: ["你已经评论过了！"], evaluation_id: evaluation.try(:id)}, status: :unprocessable_entity
    else
      if @evaluation.save
        # render :show, status: :created
        render json: {evaluation: @evaluation}, status: :created
      else
        render json: {errors: @evaluation.errors.full_messages.join(',')}, status: :unprocessable_entity
      end
    end
  end

  def thumb
    @thumb = current_user.thumbs.build(thumbable: @evaluation)
    if @thumb.save
      render json: {nickname: current_user.nickname, avatar: current_user.avatar_url}, status: :created
    else
      render json: {errors: @thumb.errors.full_messages.join(', ')}, status: :unprocessable_entity
    end
  end

  def unthumb
    @thumb = current_user.thumb.find_by(thumbable_id: @evaluation.id, thumbable_type: "Evaluation")
    @thumb.destroy if @thumb.present?

    render json: {}, status: :ok
  end

  # PATCH/PUT /evaluations/1
  # PATCH/PUT /evaluations/1.json
  # def update
  #   @evaluation = Evaluation.find(params[:id])

  #   if @evaluation.update(evaluation_params)
  #     head :no_content
  #   else
  #     render json: @evaluation.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /evaluations/1
  # DELETE /evaluations/1.json
  # def destroy
  #   @evaluation.destroy

  #   head :no_content
  # end

  private

    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    def evaluation_params
      if params[:evaluation][:pmo_grab_id].present?
        params.require(:evaluation).permit(:desc, :pmo_grab_id,
          :good, :delivery, :customer_service)
      else
        params.require(:evaluation).permit(:evaluationable_id,
          :evaluationable_type, :desc, :order_id,
          :good, :delivery, :customer_service)
      end
    end
end
