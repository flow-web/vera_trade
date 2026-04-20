# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :verify_turnstile, only: :create

  private

  def verify_turnstile
    return if Rails.env.test?

    secret = ENV["TURNSTILE_SECRET_KEY"]
    return unless secret.present?

    token = params["cf-turnstile-response"]
    response = Net::HTTP.post_form(
      URI("https://challenges.cloudflare.com/turnstile/v0/siteverify"),
      { secret: secret, response: token, remoteip: request.remote_ip }
    )
    result = JSON.parse(response.body)

    unless result["success"]
      self.resource = resource_class.new(sign_up_params)
      flash.now[:alert] = "Vérification anti-robot échouée. Veuillez réessayer."
      render :new, status: :unprocessable_entity
    end
  end
end
