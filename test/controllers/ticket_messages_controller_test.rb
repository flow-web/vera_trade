require "test_helper"

class TicketMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get ticket_messages_create_url
    assert_response :success
  end

  test "should get destroy" do
    get ticket_messages_destroy_url
    assert_response :success
  end
end
