class PwaController < ApplicationController
  skip_before_action :authenticate_user!

  def manifest
    render file: Rails.root.join("app/views/pwa/manifest.json.erb"),
           content_type: "application/manifest+json"
  end

  def service_worker
    render file: Rails.root.join("app/views/pwa/service-worker.js"),
           content_type: "text/javascript"
  end

  def offline; end
end
