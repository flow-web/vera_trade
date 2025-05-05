module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      handle_auth "Google"
    end

    def apple
      handle_auth "Apple"
    end

    def qr_code
      data = JSON.parse(params[:data])
      user = User.find_by(id: data["user_id"], email: data["email"])
      
      if user && (Time.current.to_i - data["timestamp"].to_i) < 5.minutes
        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind: "QR Code") if is_navigational_format?
      else
        redirect_to new_user_session_path, alert: "QR Code invalide ou expiré."
      end
    end

    private

    def handle_auth(kind)
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
      else
        session["devise.#{kind.downcase}_data"] = request.env["omniauth.auth"].except(:extra)
        redirect_to new_user_registration_url
      end
    end
  end
end 