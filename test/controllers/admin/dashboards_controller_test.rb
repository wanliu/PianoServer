require 'test_helper'

class Admin::DashboardsControllerTest < ActionController::TestCase
  setup do
    @admin_dashboard = admin_dashboards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_dashboards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_dashboard" do
    assert_difference('Admin::Dashboard.count') do
      post :create, admin_dashboard: {  }
    end

    assert_redirected_to admin_dashboard_path(assigns(:admin_dashboard))
  end

  test "should show admin_dashboard" do
    get :show, id: @admin_dashboard
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_dashboard
    assert_response :success
  end

  test "should update admin_dashboard" do
    patch :update, id: @admin_dashboard, admin_dashboard: {  }
    assert_redirected_to admin_dashboard_path(assigns(:admin_dashboard))
  end

  test "should destroy admin_dashboard" do
    assert_difference('Admin::Dashboard.count', -1) do
      delete :destroy, id: @admin_dashboard
    end

    assert_redirected_to admin_dashboards_path
  end
end
