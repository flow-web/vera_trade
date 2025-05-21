require "test_helper"

class WalletTransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get wallet_transactions_index_url
    assert_response :success
  end

  test "should get show" do
    get wallet_transactions_show_url
    assert_response :success
  end
end
