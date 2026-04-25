require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "index redirects unauthenticated user" do
    get dashboard_path
    assert_response :redirect
  end

  test "index renders for authenticated user" do
    sign_in users(:one)
    get dashboard_path
    assert_response :success
  end

  test "index renders for user with no listings" do
    sign_in users(:three)
    get dashboard_path
    assert_response :success
  end

  test "index assigns wallet" do
    sign_in users(:one)
    get dashboard_path
    assert_response :success
  end
end
