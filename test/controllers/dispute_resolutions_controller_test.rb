require "test_helper"

class DisputeResolutionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get dispute_resolutions_create_url
    assert_response :success
  end

  test "should get show" do
    get dispute_resolutions_show_url
    assert_response :success
  end

  test "should get update" do
    get dispute_resolutions_update_url
    assert_response :success
  end

  test "should get destroy" do
    get dispute_resolutions_destroy_url
    assert_response :success
  end

  test "should get accept" do
    get dispute_resolutions_accept_url
    assert_response :success
  end

  test "should get reject" do
    get dispute_resolutions_reject_url
    assert_response :success
  end

  test "should get implement" do
    get dispute_resolutions_implement_url
    assert_response :success
  end
end
