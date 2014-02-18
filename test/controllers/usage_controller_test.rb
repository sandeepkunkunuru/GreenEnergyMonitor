require 'test_helper'

class UsageControllerTest < ActionController::TestCase
  setup do
    @usage = usage(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:usage)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create usage" do
    assert_difference('Usage.count') do
      post :create, usage: {  }
    end

    assert_redirected_to usage_path(assigns(:usage))
  end

  test "should show usage" do
    get :show, id: @usage
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @usage
    assert_response :success
  end

  test "should update usage" do
    patch :update, id: @usage, usage: {  }
    assert_redirected_to usage_path(assigns(:usage))
  end

  test "should destroy usage" do
    assert_difference('Usage.count', -1) do
      delete :destroy, id: @usage
    end

    assert_redirected_to usage_index_path
  end
end
