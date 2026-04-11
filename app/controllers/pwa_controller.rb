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
    # We intentionally read the file into memory and `render plain:` it
    # instead of using `render file:`. In Rails 8, `render file:` with a
    # path inside `app/views/` routes through the template resolver,
    # which both (a) post-processes the content and (b) strips custom
    # response headers like `Clear-Site-Data`. `render plain:` is the
    # deterministic path: headers stick, bytes are sent verbatim.
    #
    # - `Clear-Site-Data: "cache", "storage"` tells supporting browsers to
    #   clear HTTP cache, Cache Storage AND Service Worker registrations
    #   for this origin when they fetch this response. Cookies are
    #   deliberately preserved (the `"cookies"` directive is not included).
    # - `Cache-Control: no-store` guarantees the kamikaze script itself is
    #   never cached, so rollback and re-issue stay instantaneous.
    # - `Service-Worker-Allowed: /` keeps the root scope reachable in case
    #   a later PR re-enables a real PWA worker.
    sw_body = Rails.root.join("app/views/pwa/service-worker.js").read

    headers["Clear-Site-Data"] = '"cache", "storage"'
    headers["Cache-Control"] = "no-store, max-age=0"
    headers["Service-Worker-Allowed"] = "/"

    render plain: sw_body, content_type: "text/javascript"
  end

  def offline; end
end
