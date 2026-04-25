class TwoFactorController < ApplicationController
  before_action :authenticate_user!

  def show
    @enabled = current_user.otp_required_for_login?
  end

  def setup
    secret = ROTP::Base32.random
    current_user.update!(otp_secret: secret)

    totp = ROTP::TOTP.new(secret, issuer: "Vera Trade")
    uri = totp.provisioning_uri(current_user.email)

    @qr_svg = RQRCode::QRCode.new(uri).as_svg(
      shape_rendering: "crispEdges",
      module_size: 4,
      use_path: true
    )
    @secret = secret
  end

  def enable
    totp = ROTP::TOTP.new(current_user.otp_secret)

    if totp.verify(params[:otp_code], drift_behind: 15)
      current_user.update!(otp_required_for_login: true)
      redirect_to two_factor_path, notice: "Authentification à deux facteurs activée."
    else
      redirect_to setup_two_factor_path, alert: "Code invalide. Réessayez."
    end
  end

  def disable
    totp = ROTP::TOTP.new(current_user.otp_secret)

    if totp.verify(params[:otp_code], drift_behind: 15)
      current_user.update!(otp_required_for_login: false, otp_secret: nil)
      redirect_to two_factor_path, notice: "Authentification à deux facteurs désactivée."
    else
      redirect_to two_factor_path, alert: "Code invalide."
    end
  end
end
