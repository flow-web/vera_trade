require "test_helper"

class MediaItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get media_items_create_url
    assert_response :success
  end

  test "should get destroy" do
    get media_items_destroy_url
    assert_response :success
  end
end
