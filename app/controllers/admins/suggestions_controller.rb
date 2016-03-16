class Admins::SuggestionsController < Admins::BaseController
  before_action :set_suggestion, only: [:show, :update, :destroy, :edit]

  # GET /suggestions
  # GET /suggestions.json
  def index
    @suggestions = Suggestion.avaliable
      .order(id: :asc)
      .page(params[:page])
      .per(params[:per])

    # render json: @suggestions
  end

  def uncheck
    @suggestions = Suggestion.where(check: false)
      .order(count: :desc)
      .page(params[:page])
      .per(params[:per])
  end

  # GET /suggestions/1
  # GET /suggestions/1.json
  def show
    render json: @suggestion
  end

  def edit
  end

  def new
    @suggestion = Suggestion.new(check: true)
  end

  # POST /suggestions
  # POST /suggestions.json
  def create
    @suggestion = Suggestion.new(suggestion_params)

    respond_to do |format|
      if @suggestion.save
        format.json { render json: @suggestion, status: :created }
        format.html do
          if @suggestion.check?
            redirect_to admins_suggestions_path
          else
            redirect_to uncheck_admins_suggestions_path
          end
        end
      else
        render json: @suggestion.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /suggestions/1
  # PATCH/PUT /suggestions/1.json
  def update
    @suggestion = Suggestion.find(params[:id])

    respond_to do |format|
      if @suggestion.update(suggestion_params)
        format.html { redirect_to uncheck_admins_suggestions_path }
        format.json { head :no_content }
      else
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
        format.html do
          flash.alert = @suggestion.errors.full_messages.join(',')
          render 'edit'
        end 
      end
    end
  end

  # DELETE /suggestions/1
  # DELETE /suggestions/1.json
  def destroy
    @suggestion.destroy

    respond_to do |format|
      format.json { head :no_content }
      format.html do
        if @suggestion.check?
          redirect_to admins_suggestions_path
        else
          redirect_to uncheck_admins_suggestions_path
        end
      end
    end
  end

  private

    def set_suggestion
      @suggestion = Suggestion.find(params[:id])
    end

    def suggestion_params
      params.require(:suggestion).permit(:title, :count, :check)
    end
end
