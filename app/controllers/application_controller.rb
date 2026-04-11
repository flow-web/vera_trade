class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  #
  # PWA endpoints (`manifest`, `service_worker`) are intentionally exempt so
  # that browsers of every vintage — as well as crawlers, uptime checkers
  # and Rails integration tests — can always fetch them. They are fetched
  # by the browser engine itself, not by user-facing code, and must stay
  # reachable regardless of User-Agent to allow the kamikaze SW cleanup to
  # propagate (see fix/sw-kamikaze). The `offline` fallback page stays
  # gated — it is a real HTML view shown to end users.
  allow_browser versions: :modern, except: [ :service_worker, :manifest ]

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone ])
  end
end
