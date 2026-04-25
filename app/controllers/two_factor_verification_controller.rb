class TwoFactorVerificationController < ApplicationController
  before_action :ensure_pending_2fa

  def show
  end

  def verify
    user = User.find(session[:otp_user_id])
    totp = ROTP::TOTP.new(user.otp_secret)

    if totp.verify(params[:otp_code], drift_behind: 15)
      session.delete(:otp_user_id)
      sign_in(user)
      redirect_to after_sign_in_path_for(user), notice: "Connecté avec succès."
    else
      flash.now[:alert] = "Code invalide. Réessayez."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def ensure_pending_2fa
    redirect_to new_user_session_path unless session[:otp_user_id]
  end
end
