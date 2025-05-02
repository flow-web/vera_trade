require 'cloudinary'

Cloudinary.config do |config|
  config.cloud_name = 'ddiamk7ww'
  config.api_key = '827881485326894'
  config.api_secret = 'Dc1J2o1CkN7t7T8mYeLE5dTGfYE'
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