require 'cloudinary'

Cloudinary.config do |config|
  config.cloud_name = ENV.fetch("CLOUDINARY_CLOUD_NAME")
  config.api_key    = ENV.fetch("CLOUDINARY_API_KEY")
  config.api_secret = ENV.fetch("CLOUDINARY_API_SECRET")
  config.secure = true
  config.cdn_subdomain = true
end

Rails.logger.info "Cloudinary configuration initialized"

# Configuration de la gestion des erreurs pour Cloudinary
ActiveSupport::Notifications.subscribe('service_upload.active_storage') do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  
  if event.payload[:service] == 'cloudinary'
    if event.payload[:error]
      Rails.logger.error "Cloudinary upload error: #{event.payload[:error].message}"
    else
      Rails.logger.info "Cloudinary upload success for #{event.payload[:key]}"
    end
  end
end 