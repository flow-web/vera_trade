require "cloudinary"

Cloudinary.config do |config|
  config.cloud_name = ENV["CLOUDINARY_CLOUD_NAME"]
  config.api_key    = ENV["CLOUDINARY_API_KEY"]
  config.api_secret = ENV["CLOUDINARY_API_SECRET"]
  config.secure = true
  config.cdn_subdomain = true
end

# Fail loudly at runtime if Cloudinary creds are missing in production.
# (Skipped during asset precompile via SECRET_KEY_BASE_DUMMY=1 in the Dockerfile.)
if Rails.env.production? && ENV["SECRET_KEY_BASE_DUMMY"].blank?
  missing = %w[CLOUDINARY_CLOUD_NAME CLOUDINARY_API_KEY CLOUDINARY_API_SECRET].select { |k| ENV[k].blank? }
  raise "Missing Cloudinary env vars: #{missing.join(', ')}" if missing.any?
end

Rails.logger.info "Cloudinary configuration initialized"

# Configuration de la gestion des erreurs pour Cloudinary
ActiveSupport::Notifications.subscribe("service_upload.active_storage") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  if event.payload[:service] == "cloudinary"
    if event.payload[:error]
      Rails.logger.error "Cloudinary upload error: #{event.payload[:error].message}"
    else
      Rails.logger.info "Cloudinary upload success for #{event.payload[:key]}"
    end
  end
end
