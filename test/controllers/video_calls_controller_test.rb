require "test_helper"

class VideoCallsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get video_calls_index_url
    assert_response :success
  end

  test "should get show" do
    get video_calls_show_url
    assert_response :success
  end

  test "should get create" do
    get video_calls_create_url
    assert_response :success
  end

  test "should get update" do
    get video_calls_update_url
    assert_response :success
  end

  test "should get destroy" do
    get video_calls_destroy_url
    assert_response :success
  end

  test "should get join" do
    get video_calls_join_url
    assert_response :success
  end

  test "should get leave" do
    get video_calls_leave_url
    assert_response :success
  end
end
