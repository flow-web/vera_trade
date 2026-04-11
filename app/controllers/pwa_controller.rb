class PwaController < ApplicationController
  skip_before_action :authenticate_user!

  def manifest
    render file: Rails.root.join("app/views/pwa/manifest.json.erb"),
           content_type: "application/manifest+json"
  end

  def service_worker
    # Kamikaze rollout (D1 / fix/sw-kamikaze): wipe the legacy FlowMotor
    # PWA worker from every visitor's browser.
    #
    # - `Clear-Site-Data: "cache", "storage"` tells supporting browsers to
    #   clear HTTP cache, Cache Storage AND Service Worker registrations
    #   for this origin when they fetch this response. Cookies are
    #   deliberately preserved (the `"cookies"` directive is not included).
    # - `Cache-Control: no-store` guarantees the kamikaze script itself is
    #   never cached, so rollback and re-issue stay instantaneous.
    # - `Service-Worker-Allowed: /` keeps the root scope reachable in case
    #   a later PR re-enables a real PWA worker.
    response.set_header("Clear-Site-Data", '"cache", "storage"')
    response.set_header("Cache-Control", "no-store, max-age=0")
    response.set_header("Service-Worker-Allowed", "/")

    render file: Rails.root.join("app/views/pwa/service-worker.js"),
           content_type: "text/javascript"
  end

  def offline; end
end
