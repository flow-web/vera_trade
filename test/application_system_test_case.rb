require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Devise + Warden test helpers — lets system tests bypass the UI
  # sign-in flow with `login_as(user)` / `logout`. Avoids brittle
  # click_on selectors that can collide with same-labelled nav links.
  include Warden::Test::Helpers

  setup do
    Warden.test_mode!
  end

  teardown do
    Warden.test_reset!
  end
end
