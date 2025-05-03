require "test_helper"

class MediaFoldersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get media_folders_create_url
    assert_response :success
  end

  test "should get destroy" do
    get media_folders_destroy_url
    assert_response :success
  end
end
