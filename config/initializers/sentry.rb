# Sentry error monitoring + performance tracing.
#
# DSN is read exclusively from ENV["SENTRY_DSN"]. When the DSN is absent
# (typical in local dev or CI without a secret), the entire Sentry.init
# block is skipped so Rails boots normally without reaching out to Sentry.
#
# Docs: https://docs.sentry.io/platforms/ruby/guides/rails/

return if ENV["SENTRY_DSN"].blank?

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]

  # Separate issue streams per environment (development / test / staging / production).
  config.environment = Rails.env

  # Tag each event with the deployed commit SHA when available so stack
  # traces can be deep-linked back to source in the Sentry UI.
  config.release = ENV["GIT_SHA"] || ENV["RAILS_RELEASE"] || "unknown"

  # Breadcrumbs: capture ActiveSupport notifications and HTTP calls for context.
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  # Send structured Rails logger output to Sentry (errors + warnings only).
  # Lower verbosity to avoid noise and cap ingest volume on the free tier.

  # Performance monitoring — sample 20% of requests in production, 100% in
  # non-prod so we get enough traces without burning the free-tier quota.
  config.traces_sample_rate = Rails.env.production? ? 0.2 : 1.0

  # Profile 10% of sampled traces when running on a supported MRI Ruby.
  config.profiles_sample_rate = Rails.env.production? ? 0.1 : 0.5

  # Do NOT send potentially sensitive PII (emails, IPs, session cookies)
  # to Sentry — toggle on once we have a DPA with them and user consent.
  config.send_default_pii = false

  # Filter secrets and auth tokens out of any captured request data as a
  # defense-in-depth layer on top of Rails' own parameter filters.
  config.before_send = lambda do |event, _hint|
    event.request&.data&.deep_transform_values! do |value|
      next value unless value.is_a?(String)
      # Redact anything that looks like a token (32+ hex chars or JWT-ish).
      value.match?(/\A[A-Fa-f0-9]{32,}\z/) || value.match?(/\Aey[A-Za-z0-9_\-]+\.ey/) ? "[FILTERED]" : value
    end
    event
  end

  # Ignore noisy errors that don't warrant a Sentry issue.
  config.excluded_exceptions += %w[
    ActionController::RoutingError
    ActionController::InvalidAuthenticityToken
    ActiveRecord::RecordNotFound
  ]
end
