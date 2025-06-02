class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  protect_from_forgery with: :exception, except: [:test_direct_login]
  before_action :authenticate_user!, except: [:test_login, :test_direct_login]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  
  # Test methods for debugging login issues
  def test_login
    @user = User.find_by(email: 'test@example.com')
    render plain: "Test user exists: #{@user.present?}. Password check: #{@user&.valid_password?('password123')}"
  end
  
  def test_direct_login
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      sign_in(user)
      redirect_to dashboard_path, notice: 'Successfully logged in!'
    else
      render plain: "Login failed. User found: #{user.present?}. Email: #{params[:email]}"
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end
  
  private
  
  def set_locale
    I18n.locale = :fr
  end
end
