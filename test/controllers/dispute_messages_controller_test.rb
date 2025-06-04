require "test_helper"

class DisputeMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get dispute_messages_create_url
    assert_response :success
  end

  test "should get destroy" do
    get dispute_messages_destroy_url
    assert_response :success
  end
end
