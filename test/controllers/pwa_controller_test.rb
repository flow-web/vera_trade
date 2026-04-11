require "test_helper"

class PwaControllerTest < ActionDispatch::IntegrationTest
  # D1 / fix/sw-kamikaze — guards the contract that /service-worker.js
  # actively dismantles the legacy FlowMotor PWA on any browser that
  # still talks to this origin. Any future PWA work must either update
  # these assertions deliberately or add a migration path.

  test "service_worker responds successfully with a javascript body" do
    get "/service-worker.js"

    assert_response :success
    assert_equal "text/javascript", response.media_type
  end

  test "service_worker sets Clear-Site-Data header to wipe cache and storage" do
    get "/service-worker.js"

    clear_site_data = response.headers["Clear-Site-Data"]
    assert_not_nil clear_site_data, "Clear-Site-Data header must be present"
    assert_includes clear_site_data, '"cache"', "must clear HTTP + Cache Storage"
    assert_includes clear_site_data, '"storage"',
                    "must clear Service Worker registrations + web storage"
    assert_not_includes clear_site_data, '"cookies"',
                        "cookies are deliberately preserved so users stay signed in"
  end

  test "service_worker is never cached by browsers or proxies" do
    get "/service-worker.js"

    cache_control = response.headers["Cache-Control"]
    assert_not_nil cache_control, "Cache-Control header must be present"
    assert_includes cache_control, "no-store",
                    "kamikaze script must never be cached so rollback stays instant"
  end

  test "service_worker advertises root scope via Service-Worker-Allowed" do
    get "/service-worker.js"

    assert_equal "/", response.headers["Service-Worker-Allowed"]
  end

  test "service_worker body unregisters itself and clears Cache Storage" do
    get "/service-worker.js"

    body = response.body
    assert_includes body, "self.registration.unregister",
                    "kamikaze body must unregister the worker"
    assert_includes body, "caches.delete",
                    "kamikaze body must wipe Cache Storage"
    assert_includes body, "self.skipWaiting",
                    "kamikaze must skip the waiting phase to take over immediately"
    assert_not_includes body, 'addEventListener("fetch"',
                        "kamikaze must NOT register a fetch handler — " \
                        "requests must pass straight through to the network"
  end

  test "manifest route still serves the PWA manifest JSON" do
    get "/manifest.webmanifest"

    assert_response :success
    assert_equal "application/manifest+json", response.media_type
  end

  # D1.5 / fix/pwa-reset-endpoint — guard the manual cleanup escape hatch
  # that early testers hit when Safari iOS or Chrome mobile refuses to
  # evict the legacy FlowMotor SW on its own.

  test "reset responds with an HTML page" do
    get "/reset"

    assert_response :success
    assert_equal "text/html", response.media_type
  end

  test "reset sends Clear-Site-Data to wipe cache and storage on the browser" do
    get "/reset"

    clear_site_data = response.headers["Clear-Site-Data"]
    assert_not_nil clear_site_data, "Clear-Site-Data header must be present"
    assert_includes clear_site_data, '"cache"'
    assert_includes clear_site_data, '"storage"'
    assert_not_includes clear_site_data, '"cookies"',
                        "reset must preserve cookies so users stay signed in"
  end

  test "reset is never cached by browsers or proxies" do
    get "/reset"

    assert_includes response.headers["Cache-Control"].to_s, "no-store"
  end

  test "reset page redirects to home via meta refresh" do
    get "/reset"

    assert_includes response.body, 'http-equiv="refresh"'
    assert_includes response.body, "url=/",
                    "meta refresh must point back to the homepage"
    assert_includes response.body, "Nettoyage du cache",
                    "user-facing message must be present"
    assert_includes response.body, 'href="/"',
                    "manual fallback link must be present if meta refresh fails"
  end
end
