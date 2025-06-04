require "test_helper"

class DisputeEvidencesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get dispute_evidences_create_url
    assert_response :success
  end

  test "should get show" do
    get dispute_evidences_show_url
    assert_response :success
  end

  test "should get destroy" do
    get dispute_evidences_destroy_url
    assert_response :success
  end
end
