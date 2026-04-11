require "application_system_test_case"

class SwKamikazeTest < ApplicationSystemTestCase
  # D1 / fix/sw-kamikaze — Capybara happy path guarding the visible
  # contract of the Service Worker cleanup:
  #
  #   1. The homepage still loads normally after removing the SW
  #      registration script (no JS error, brand title present).
  #   2. The rendered HTML does NOT contain any
  #      `navigator.serviceWorker.register(...)` call. If it did, the
  #      kamikaze worker would install itself again on every page load
  #      and create an install/kamikaze reload loop.
  #
  # When we eventually re-enable a real PWA, THIS is the test that must
  # be updated intentionally — not silently deleted.

  test "homepage loads and does not register a service worker from the layout" do
    visit root_path

    assert_title(/Vera Trade/)

    html_source = page.html
    assert_no_match(
      /navigator\.serviceWorker\.register/,
      html_source,
      "The layout must not register a service worker while the kamikaze " \
      "cleanup is in effect — otherwise the install/kamikaze loop returns."
    )
  end
end
