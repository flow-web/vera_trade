require "test_helper"

class HelpControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get help_index_url
    assert_response :success
  end

  test "should get dispute_guidelines" do
    get help_dispute_guidelines_url
    assert_response :success
  end

  test "should get support_faq" do
    get help_support_faq_url
    assert_response :success
  end
end
