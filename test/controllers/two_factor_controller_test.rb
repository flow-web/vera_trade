require "test_helper"

class TwoFactorControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "show displays 2FA status" do
    get two_factor_path
    assert_response :success
  end

  test "setup generates QR code and secret" do
    get setup_two_factor_path
    assert_response :success
    @user.reload
    assert_not_nil @user.otp_secret
  end

  test "enable with valid code activates 2FA" do
    @user.update!(otp_secret: ROTP::Base32.random)
    totp = ROTP::TOTP.new(@user.otp_secret)

    post enable_two_factor_path, params: { otp_code: totp.now }
    assert_redirected_to two_factor_path

    @user.reload
    assert @user.otp_required_for_login
  end

  test "enable with invalid code rejects" do
    @user.update!(otp_secret: ROTP::Base32.random)

    post enable_two_factor_path, params: { otp_code: "000000" }
    assert_redirected_to setup_two_factor_path
  end

  test "disable with valid code deactivates 2FA" do
    secret = ROTP::Base32.random
    @user.update!(otp_secret: secret, otp_required_for_login: true)
    totp = ROTP::TOTP.new(secret)

    delete two_factor_path, params: { otp_code: totp.now }
    assert_redirected_to two_factor_path

    @user.reload
    assert_not @user.otp_required_for_login
    assert_nil @user.otp_secret
  end
end
