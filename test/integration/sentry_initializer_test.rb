require "test_helper"

# Unit test for config/initializers/sentry.rb.
#
# Contract: the initializer must be a no-op when ENV["SENTRY_DSN"] is
# absent, so local dev / CI / any environment without a DSN still boots
# Rails cleanly. This test verifies that contract by asserting Sentry
# stays uninitialized under the default test env (no SENTRY_DSN set).
class SentryInitializerTest < ActiveSupport::TestCase
  test "Sentry is not initialized when SENTRY_DSN is blank" do
    assert ENV["SENTRY_DSN"].blank?, "test env must not leak a SENTRY_DSN"
    refute Sentry.initialized?, "Sentry must skip init when DSN is blank"
  end

  test "Sentry gem is loaded and Sentry constant is available" do
    assert defined?(Sentry), "sentry-ruby gem must be required by bundler"
    assert_respond_to Sentry, :init
    assert_respond_to Sentry, :capture_exception
  end
end
