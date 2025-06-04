require "test_helper"

class SupportTicketsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get support_tickets_index_url
    assert_response :success
  end

  test "should get show" do
    get support_tickets_show_url
    assert_response :success
  end

  test "should get new" do
    get support_tickets_new_url
    assert_response :success
  end

  test "should get create" do
    get support_tickets_create_url
    assert_response :success
  end

  test "should get edit" do
    get support_tickets_edit_url
    assert_response :success
  end

  test "should get update" do
    get support_tickets_update_url
    assert_response :success
  end

  test "should get destroy" do
    get support_tickets_destroy_url
    assert_response :success
  end
end
