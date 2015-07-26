class Admins::DashboardsController < ApplicationController
  before_action :set_admin_dashboard, only: [:show, :edit, :update, :destroy]

  # GET /admin/dashboards
  # GET /admin/dashboards.json
  def index
    # @admin_dashboards = Admin::Dashboard.all
  end

  # GET /admin/dashboards/1
  # GET /admin/dashboards/1.json
  def show
  end

  # GET /admin/dashboards/new
  def new
    @admin_dashboard = Admin::Dashboard.new
  end

  # GET /admin/dashboards/1/edit
  def edit
  end

  # POST /admin/dashboards
  # POST /admin/dashboards.json
  def create
    @admin_dashboard = Admin::Dashboard.new(admin_dashboard_params)

    respond_to do |format|
      if @admin_dashboard.save
        format.html { redirect_to @admin_dashboard, notice: 'Dashboard was successfully created.' }
        format.json { render :show, status: :created, location: @admin_dashboard }
      else
        format.html { render :new }
        format.json { render json: @admin_dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/dashboards/1
  # PATCH/PUT /admin/dashboards/1.json
  def update
    respond_to do |format|
      if @admin_dashboard.update(admin_dashboard_params)
        format.html { redirect_to @admin_dashboard, notice: 'Dashboard was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_dashboard }
      else
        format.html { render :edit }
        format.json { render json: @admin_dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/dashboards/1
  # DELETE /admin/dashboards/1.json
  def destroy
    @admin_dashboard.destroy
    respond_to do |format|
      format.html { redirect_to admin_dashboards_url, notice: 'Dashboard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_dashboard
      @admin_dashboard = Admin::Dashboard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_dashboard_params
      params[:admin_dashboard]
    end
end
