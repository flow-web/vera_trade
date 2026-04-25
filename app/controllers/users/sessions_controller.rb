module Users
  class SessionsController < Devise::SessionsController
    def create
      self.resource = warden.authenticate!(auth_options)

      if resource.otp_required_for_login?
        sign_out(resource)
        session[:otp_user_id] = resource.id
        redirect_to two_factor_verify_path
        return
      end

      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end
end
