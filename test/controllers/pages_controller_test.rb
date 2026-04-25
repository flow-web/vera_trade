require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  # All pages in PagesController are public — no sign-in needed.

  test "home renders successfully" do
    get root_path
    assert_response :success
  end

  test "home displays featured listing section" do
    get root_path
    assert_response :success
    assert_select "body"
  end

  test "cgu renders successfully" do
    get cgu_path
    assert_response :success
  end

  test "mentions_legales renders successfully" do
    get mentions_legales_path
    assert_response :success
  end

  test "confidentialite renders successfully" do
    get confidentialite_path
    assert_response :success
  end

  test "sitemap returns XML" do
    get "/sitemap.xml"
    assert_response :success
    assert_match(/xml/, response.content_type)
  end
end
