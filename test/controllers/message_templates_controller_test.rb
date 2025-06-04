require "test_helper"

class MessageTemplatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get message_templates_index_url
    assert_response :success
  end

  test "should get create" do
    get message_templates_create_url
    assert_response :success
  end

  test "should get update" do
    get message_templates_update_url
    assert_response :success
  end

  test "should get destroy" do
    get message_templates_destroy_url
    assert_response :success
  end
end
