Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data, "https://fonts.gstatic.com", "https://cdnjs.cloudflare.com"
    policy.img_src     :self, :data, :https
    policy.object_src  :none
    policy.script_src  :self, "https://cdnjs.cloudflare.com"
    policy.style_src   :self, :unsafe_inline, "https://fonts.googleapis.com", "https://cdnjs.cloudflare.com"
    policy.connect_src :self, "wss://veratrade.fr"
    policy.frame_src   :none
    policy.base_uri    :self
  end

  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
